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
    WINDOWS_HOST = RbConfig::CONFIG['host_os'].match?(/mswin|mingw|cygwin/i)
    ARCHIVE_COMMAND = WINDOWS_HOST ? 'tar' : 'bsdtar'

    def run_command(*arguments, chdir: nil, allow_failure: false, environment: {})
      options = {}
      options[:chdir] = chdir unless chdir.nil?
      stdout, stderr, status = Open3.capture3(environment, *arguments, options)
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
      run_command(ARCHIVE_COMMAND, '-cf', box, *entries, chdir: contents)
      box
    end

    def extract_box(box, directory)
      FileUtils.mkdir_p(directory)
      run_command(ARCHIVE_COMMAND, '-xf', box, '-C', directory)
    end

    def run_module(command, artifact_directory, allow_failure: false, environment: {})
      run_command(RbConfig.ruby, SCRIPT, command, artifact_directory, allow_failure: allow_failure, environment: environment)
    end

    def executable_path(command)
      extensions = RbConfig::CONFIG['host_os'].match?(/mswin|mingw|cygwin/i) ? ['', '.exe'] : ['']
      ENV.fetch('PATH').split(File::PATH_SEPARATOR).each do |directory|
        extensions.each do |extension|
          candidate = File.join(directory, "#{command}#{extension}")
          return candidate if File.file?(candidate) && File.executable?(candidate)
        end
      end
      raise "required test executable not found: #{command}"
    end

    def assert_no_temporary_content(root, artifact_basename)
      prefix = ".#{artifact_basename}.vagrant-box-"
      leftovers = Dir.children(root).select { |entry| entry.start_with?(prefix) }
      assert(leftovers.empty?, "temporary artifact-transfer content was not cleaned: #{leftovers.join(', ')}")
    end

    def install_test_tool(source, directory)
      destination = File.join(directory, File.basename(source))
      WINDOWS_HOST ? FileUtils.cp(source, destination) : FileUtils.ln_s(source, destination)
    end

    def generic_round_trip
      Dir.mktmpdir('vagrant-box-round-trip-') do |root|
        artifact = File.join(root, 'artifact')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(vagrant)
        FileUtils.cp(write_box(root, provider: 'virtualbox', files: { 'disk.vmdk' => 'disk contents' }), File.join(vagrant, 'vagrant.box'))

        source_box = File.join(vagrant, 'vagrant.box')
        input_size = File.size(source_box)
        assert(File.binread(source_box, 2) != "\x1F\x8B".b, 'test input is not an uncompressed Packer-style box')

        prepare_stdout, _prepare_stderr, _prepare_status = run_module('prepare', artifact)

        assert(File.binread(File.join(artifact, 'image', 'disk.vmdk')) == 'disk contents', 'prepare did not promote unpacked box contents')
        metadata = JSON.parse(File.read(File.join(artifact, 'image', 'metadata.json')))
        assert(metadata['provider'] == 'virtualbox', 'prepare changed provider metadata')
        assert(File.binread(source_box, 2) != "\x1F\x8B".b, 'prepare compressed the normalized test box')
        prepare_result = JSON.parse(prepare_stdout)
        assert(prepare_result['input_size_bytes'] == input_size, 'prepare input size does not describe the Packer box')
        assert(prepare_result['extraction_duration_seconds'].is_a?(Numeric), 'prepare did not record extraction duration')
        assert(prepare_result['packaging_duration_seconds'].is_a?(Numeric), 'prepare did not record packaging duration')
        assert(prepare_result['output_size_bytes'] == File.size(source_box), 'prepare output size does not describe the test box')
        assert(prepare_result['outcome'] == 'passed', 'prepare did not record its functional outcome')

        FileUtils.rm_rf(vagrant)
        restore_stdout, _restore_stderr, _restore_status = run_module('restore', artifact)

        publication_box = File.join(vagrant, 'vagrant.box')
        assert(File.binread(publication_box, 2) == "\x1F\x8B".b, 'restore did not produce a gzip-compressed publication box')
        restore_result = JSON.parse(restore_stdout)
        checksum = Digest::SHA256.file(publication_box).hexdigest
        assert(restore_result['input_size_bytes'].positive?, 'restore did not record input size')
        assert(restore_result['compression_duration_seconds'].is_a?(Numeric), 'restore did not record compression duration')
        assert(restore_result['output_size_bytes'] == File.size(publication_box), 'restore output size does not describe the publication box')
        assert(restore_result['outcome'] == 'passed', 'restore did not record its functional outcome')
        restored = File.join(root, 'restored')
        extract_box(publication_box, restored)
        assert(File.binread(File.join(restored, 'disk.vmdk')) == 'disk contents', 'restore did not package transferred contents')
        assert(JSON.parse(File.read(File.join(restored, 'metadata.json')))['provider'] == 'virtualbox', 'restore changed provider metadata')
        assert_no_temporary_content(root, 'artifact')
        puts JSON.generate(
          event: 'artifact_transfer_measurement',
          input_size_bytes: prepare_result['input_size_bytes'],
          extraction_duration_seconds: prepare_result['extraction_duration_seconds'],
          packaging_duration_seconds: prepare_result['packaging_duration_seconds'],
          test_box_size_bytes: prepare_result['output_size_bytes'],
          compression_duration_seconds: restore_result['compression_duration_seconds'],
          publication_box_size_bytes: restore_result['output_size_bytes'],
          sha256: checksum,
          checksum_result: 'passed',
          outcome: 'passed'
        )
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
        previous_image = File.join(artifact, 'image')
        FileUtils.mkdir_p(vagrant)
        FileUtils.mkdir_p(previous_image)
        File.binwrite(File.join(previous_image, 'recoverable.txt'), 'prior normalized image')
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
        assert(File.binread(File.join(previous_image, 'recoverable.txt')) == 'prior normalized image', 'failed prepare did not preserve the prior normalized image')
        assert_no_temporary_content(root, 'artifact')
      end
    end

    def missing_hyperv_configuration_is_actionable
      Dir.mktmpdir('vagrant-box-hyperv-missing-') do |root|
        artifact = File.join(root, 'artifact')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(vagrant)
        files = {
          File.join('Virtual Machines', 'box.xml') => 'obsolete configuration',
          File.join('Virtual Hard Disks', 'disk.vhdx') => 'disk contents'
        }
        box = File.join(vagrant, 'vagrant.box')
        FileUtils.cp(write_box(root, provider: 'hyperv', files: files), box)
        original_sha256 = Digest::SHA256.file(box).hexdigest

        _stdout, stderr, status = run_module('prepare', artifact, allow_failure: true)

        assert(!status.success?, 'prepare accepted a missing Hyper-V VM configuration')
        assert(stderr.include?('exactly one .vmcx') && stderr.include?('found 0'), 'prepare did not explain the missing Hyper-V VM configuration')
        assert(Digest::SHA256.file(box).hexdigest == original_sha256, 'missing Hyper-V configuration failure did not preserve the original box')
        assert_no_temporary_content(root, 'artifact')
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
        assert_no_temporary_content(root, 'artifact')
      end
    end

    def invalid_provider_metadata_is_actionable
      Dir.mktmpdir('vagrant-box-provider-') do |root|
        artifact = File.join(root, 'artifact')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(vagrant)
        box = write_box(root, provider: '', files: { 'disk.vmdk' => 'disk contents' })
        FileUtils.cp(box, File.join(vagrant, 'vagrant.box'))

        _stdout, stderr, status = run_module('prepare', artifact, allow_failure: true)

        assert(!status.success?, 'prepare accepted an empty metadata provider')
        assert(stderr.include?('provider must be a non-empty string'), 'prepare did not explain the invalid provider metadata')
        assert_no_temporary_content(root, 'artifact')
      end
    end

    def malformed_archive_is_actionable
      Dir.mktmpdir('vagrant-box-archive-') do |root|
        artifact = File.join(root, 'artifact')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(vagrant)
        box = File.join(vagrant, 'vagrant.box')
        File.binwrite(box, 'not a tar archive')
        original_sha256 = Digest::SHA256.file(box).hexdigest

        _stdout, stderr, status = run_module('prepare', artifact, allow_failure: true)

        assert(!status.success?, 'prepare accepted a malformed input archive')
        assert(stderr.include?('failed'), 'prepare did not report the archive extraction failure')
        assert(Digest::SHA256.file(box).hexdigest == original_sha256, 'archive failure did not preserve the malformed input')
        assert_no_temporary_content(root, 'artifact')
      end
    end

    def empty_image_is_actionable
      Dir.mktmpdir('vagrant-box-empty-') do |root|
        artifact = File.join(root, 'artifact')
        image = File.join(artifact, 'image')
        FileUtils.mkdir_p(image)

        _stdout, stderr, status = run_module('restore', artifact, allow_failure: true)

        assert(!status.success?, 'restore accepted an empty image')
        assert(stderr.include?('Vagrant metadata does not exist'), 'restore did not explain the empty image failure')
        assert_no_temporary_content(root, 'artifact')
      end
    end

    def missing_pigz_preserves_prior_output
      Dir.mktmpdir('vagrant-box-pigz-') do |root|
        artifact = File.join(root, 'artifact')
        image = File.join(artifact, 'image')
        vagrant = File.join(artifact, 'vagrant')
        FileUtils.mkdir_p(image)
        FileUtils.mkdir_p(vagrant)
        File.write(File.join(image, 'metadata.json'), JSON.generate({ provider: 'virtualbox' }))
        File.binwrite(File.join(image, 'disk.vmdk'), 'disk contents')
        box = File.join(vagrant, 'vagrant.box')
        File.binwrite(box, 'recoverable publication box')

        tools = File.join(root, 'tools')
        FileUtils.mkdir_p(tools)
        archive = executable_path(ARCHIVE_COMMAND)
        install_test_tool(archive, tools)
        begin
          uname = executable_path('uname')
          install_test_tool(uname, tools)
        rescue RuntimeError
          # Ruby only shells out to uname during startup on hosts that provide it.
        end
        environment = { 'PATH' => tools }

        _stdout, stderr, status = run_module('restore', artifact, allow_failure: true, environment: environment)

        assert(!status.success?, 'restore accepted a missing pigz executable')
        assert(stderr.include?('pigz') && stderr.include?('required'), "restore did not explain the missing pigz dependency: #{stderr}")
        assert(File.binread(box) == 'recoverable publication box', 'missing pigz failure did not preserve the prior publication box')
        assert(File.binread(File.join(image, 'disk.vmdk')) == 'disk contents', 'missing pigz failure changed the transferred image')
        assert_no_temporary_content(root, 'artifact')
      end
    end

    def run
      generic_round_trip
      puts 'generic round trip: passed'
      hyperv_correction
      puts 'Hyper-V correction: passed'
      preparation_failure_preserves_original_box
      puts 'preparation rollback: passed'
      missing_hyperv_configuration_is_actionable
      puts 'missing Hyper-V configuration: passed'
      malformed_metadata_is_actionable
      puts 'metadata failure: passed'
      invalid_provider_metadata_is_actionable
      puts 'provider metadata failure: passed'
      malformed_archive_is_actionable
      puts 'archive failure: passed'
      empty_image_is_actionable
      puts 'empty image failure: passed'
      missing_pigz_preserves_prior_output
      puts 'missing pigz rollback: passed'
    end
  end
end

ArtifactTransfer::VagrantBoxIntegrationTest.run
