require 'fileutils'
require 'digest'
require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'

module ArtifactTransfer
  module VagrantBoxIntegrationTest
    module_function

    SCRIPT = File.expand_path('vagrant_box.rb', __dir__).freeze
    ARCHIVE_COMMAND = RbConfig::CONFIG['host_os'].match?(/mswin|mingw|cygwin/i) ? 'tar' : 'bsdtar'

    def run_command(*arguments, chdir: nil, allow_failure: false)
      options = {}
      options[:chdir] = chdir unless chdir.nil?
      stdout, stderr, status = Open3.capture3(*arguments, options)
      return [stdout, stderr, status] if status.success? || allow_failure

      raise "#{arguments.join(' ')} failed (#{status.exitstatus}):\n#{stdout}#{stderr}"
    end

    def assert(condition, message)
      raise message unless condition
    end

    def write_box(directory, provider:, files: {})
      contents = File.join(directory, 'contents')
      FileUtils.mkdir_p(contents)
      File.write(File.join(contents, 'metadata.json'), JSON.generate({ provider: provider }))
      files.each do |relative_path, body|
        path = File.join(contents, relative_path)
        FileUtils.mkdir_p(File.dirname(path))
        File.binwrite(path, body)
      end
      box = File.join(directory, 'vagrant.box')
      entries = Dir.children(contents).sort
      run_command(ARCHIVE_COMMAND, '-czf', box, *entries, chdir: contents)
      box
    end

    def extract_box(box, directory)
      FileUtils.mkdir_p(directory)
      run_command(ARCHIVE_COMMAND, '-xf', box, '-C', directory)
    end

    def run_module(command, artifact_directory, allow_failure: false)
      run_command(RbConfig.ruby, SCRIPT, command, artifact_directory, allow_failure: allow_failure)
    end

    def generic_round_trip
      Dir.mktmpdir('vagrant-box-round-trip-') do |root|
        artifact = File.join(root, 'artifact')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(vagrant)
        FileUtils.cp(write_box(root, provider: 'virtualbox', files: { 'disk.vmdk' => 'disk contents' }), File.join(vagrant, 'vagrant.box'))

        run_module('prepare', artifact)

        assert(File.binread(File.join(artifact, 'image', 'disk.vmdk')) == 'disk contents', 'prepare did not promote unpacked box contents')
        metadata = JSON.parse(File.read(File.join(artifact, 'image', 'metadata.json')))
        assert(metadata['provider'] == 'virtualbox', 'prepare changed provider metadata')

        FileUtils.rm_rf(vagrant)
        run_module('restore', artifact)

        restored = File.join(root, 'restored')
        extract_box(File.join(vagrant, 'vagrant.box'), restored)
        assert(File.binread(File.join(restored, 'disk.vmdk')) == 'disk contents', 'restore did not package transferred contents')
        assert(JSON.parse(File.read(File.join(restored, 'metadata.json')))['provider'] == 'virtualbox', 'restore changed provider metadata')
      end
    end

    def hyperv_correction
      Dir.mktmpdir('vagrant-box-hyperv-') do |root|
        artifact = File.join(root, 'artifact')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(vagrant)
        files = {
          File.join('Virtual Machines', 'box.xml') => 'obsolete configuration',
          File.join('Virtual Machines', 'machine.vmcx') => 'vm configuration',
          File.join('Virtual Hard Disks', 'disk.vhdx') => 'disk contents'
        }
        FileUtils.cp(write_box(root, provider: 'hyperv', files: files), File.join(vagrant, 'vagrant.box'))

        run_module('prepare', artifact)

        assert(!File.exist?(File.join(artifact, 'image', 'Virtual Machines', 'box.xml')), 'prepare retained Hyper-V box.xml')
        assert(File.file?(File.join(artifact, 'image', 'Virtual Machines', 'machine.vmcx')), 'prepare removed the Hyper-V VM configuration')
        packaged = File.join(root, 'packaged')
        extract_box(File.join(vagrant, 'vagrant.box'), packaged)
        assert(!File.exist?(File.join(packaged, 'Virtual Machines', 'box.xml')), 'repackaged Hyper-V box retained box.xml')
      end
    end

    def preparation_failure_preserves_original_box
      Dir.mktmpdir('vagrant-box-failure-') do |root|
        artifact = File.join(root, 'artifact')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(vagrant)
        files = {
          File.join('Virtual Machines', 'box.xml') => 'obsolete configuration',
          File.join('Virtual Machines', 'first.vmcx') => 'first configuration',
          File.join('Virtual Machines', 'second.vmcx') => 'second configuration'
        }
        box = File.join(vagrant, 'vagrant.box')
        FileUtils.cp(write_box(root, provider: 'hyperv', files: files), box)
        original_sha256 = Digest::SHA256.file(box).hexdigest

        _stdout, stderr, status = run_module('prepare', artifact, allow_failure: true)

        assert(!status.success?, 'prepare accepted an ambiguous Hyper-V configuration')
        assert(stderr.include?('exactly one .vmcx'), 'prepare did not explain the Hyper-V configuration failure')
        assert(Digest::SHA256.file(box).hexdigest == original_sha256, 'failed prepare did not preserve the original Packer box')
        assert(!File.exist?(File.join(artifact, 'image')), 'failed prepare promoted a partial image')
      end
    end

    def malformed_metadata_is_actionable
      Dir.mktmpdir('vagrant-box-metadata-') do |root|
        artifact = File.join(root, 'artifact')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(vagrant)
        box = write_box(root, provider: 'virtualbox', files: { 'disk.vmdk' => 'disk contents' })
        contents = File.join(root, 'malformed')
        extract_box(box, contents)
        File.write(File.join(contents, 'metadata.json'), '{')
        malformed_box = File.join(vagrant, 'vagrant.box')
        entries = Dir.children(contents).sort
        run_command(ARCHIVE_COMMAND, '-czf', malformed_box, *entries, chdir: contents)
        original_sha256 = Digest::SHA256.file(malformed_box).hexdigest

        _stdout, stderr, status = run_module('prepare', artifact, allow_failure: true)

        assert(!status.success?, 'prepare accepted malformed metadata')
        assert(stderr.include?('not valid JSON'), 'prepare did not explain the metadata failure')
        assert(Digest::SHA256.file(malformed_box).hexdigest == original_sha256, 'metadata failure did not preserve the original Packer box')
      end
    end

    def run
      generic_round_trip
      puts 'generic round trip: passed'
      hyperv_correction
      puts 'Hyper-V correction: passed'
      preparation_failure_preserves_original_box
      puts 'preparation rollback: passed'
      malformed_metadata_is_actionable
      puts 'metadata failure: passed'
    end
  end
end

ArtifactTransfer::VagrantBoxIntegrationTest.run
