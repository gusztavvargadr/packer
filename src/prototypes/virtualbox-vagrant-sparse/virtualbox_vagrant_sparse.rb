# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'rbconfig'

SCHEMA = 'virtualbox-vagrant/sparse-box/v1'

def run_command(*arguments)
  return if system(*arguments)

  raise "#{arguments.join(' ')} failed"
end

def file_state(path)
  {
    'bytes' => File.size(path),
    'sha256' => Digest::SHA256.file(path).hexdigest
  }
end

def canonical_state(artifact_root)
  manifest_path = File.join(artifact_root, 'virtualbox-native-producer-prototype.json')
  manifest = JSON.parse(File.read(manifest_path))
  files = manifest.fetch('canonical').fetch('files')
  extensions = files.map { |file| File.extname(file.fetch('path')) }.sort
  unless extensions == %w[.nvram .ovf .vmdk]
    raise "expected canonical OVF, VMDK, and NVRAM, found #{extensions.join(', ')}"
  end

  variant = manifest.fetch('canonical_disk').fetch('format_variant')
  raise "canonical VMDK is compressed: #{variant}" if variant.include?('streamOptimized')

  [manifest_path, files]
end

def representative(artifact_root, architecture, transfer_helper)
  artifact_root = File.expand_path(artifact_root)
  prototype_root = File.expand_path(__dir__)
  producer = File.expand_path('../virtualbox-native-producer/virtualbox_native_producer.rb', __dir__)
  package = File.join(prototype_root, 'package.pkr.hcl')

  run_command(RbConfig.ruby, producer, 'vagrant-representative', artifact_root)
  producer_manifest, expected_files = canonical_state(artifact_root)
  FileUtils.mkdir_p(File.join(artifact_root, 'vagrant'))
  FileUtils.rm_f(File.join(artifact_root, 'checksum.sha256'))

  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  run_command(ENV.fetch('PACKER', 'packer'), 'init', package)
  run_command(
    ENV.fetch('PACKER', 'packer'), 'build', '-force',
    '-var', "architecture=#{architecture}",
    '-var', "artifact_root=#{artifact_root}",
    package
  )
  package_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started

  box = File.join(artifact_root, 'vagrant', 'vagrant.box')
  verification_path = File.join(artifact_root, 'virtualbox-vagrant-sparse-verification.json')
  run_command(transfer_helper, 'verify-virtualbox-sparse-box', box, producer_manifest, architecture, verification_path)
  state = JSON.parse(File.read(verification_path))
  checksum = File.read(File.join(artifact_root, 'checksum.sha256')).split.first
  raise 'generated checksum does not match vagrant.box' unless checksum == state.fetch('box').fetch('sha256')

  result = {
    'schema' => SCHEMA,
    'host_os' => RbConfig::CONFIG.fetch('host_os'),
    'host_architecture' => RbConfig::CONFIG.fetch('host_cpu'),
    'package_seconds' => package_seconds,
    'canonical_files' => expected_files,
    'result' => state
  }
  contents = "#{JSON.pretty_generate(result)}\n"
  File.write(File.join(artifact_root, 'virtualbox-vagrant-sparse-prototype.json'), contents)
  puts JSON.pretty_generate(result)
end

def main(arguments)
  command, *command_arguments = arguments
  case [command, command_arguments.length]
  when ['representative', 3]
    representative(*command_arguments)
    0
  else
    warn [
      'usage: ruby virtualbox_vagrant_sparse.rb representative',
      '<vagrant-artifact-directory> <architecture> <vagrant-transfer-helper>'
    ].join(' ')
    1
  end
end

exit main(ARGV) if $PROGRAM_NAME == __FILE__
