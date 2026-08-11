require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'

module ArtifactTransfer
  module VagrantBox
    module_function

    BOX_PATH = File.join('vagrant', 'vagrant.box').freeze
    IMAGE_PATH = 'image'.freeze
    METADATA_PATH = 'metadata.json'.freeze
    ARCHIVE_COMMAND = RbConfig::CONFIG['host_os'].match?(/darwin|mswin|mingw|cygwin/i) ? 'tar' : 'bsdtar'
    PIGZ_COMMAND = 'pigz'.freeze

    def run_command(*arguments, chdir: nil)
      options = {}
      options[:chdir] = chdir unless chdir.nil?
      stdout, stderr, status = Open3.capture3(*arguments, options)
      return stdout if status.success?

      details = [stdout, stderr].reject(&:empty?).join
      raise "#{arguments.join(' ')} failed (#{status.exitstatus}):\n#{details}"
    end

    def require_directory(path, description)
      raise "#{description} does not exist: #{path}" unless File.directory?(path)
    end

    def require_file(path, description)
      raise "#{description} does not exist: #{path}" unless File.file?(path)
    end

    def validate_tool(command, description)
      run_command(command, '--version')
    rescue Errno::ENOENT
      raise "#{description} is required but was not found: #{command}"
    end

    def provider(image)
      metadata_path = File.join(image, METADATA_PATH)
      require_file(metadata_path, 'Vagrant metadata')
      metadata = JSON.parse(File.read(metadata_path))
      raise "Vagrant metadata must be a JSON object: #{metadata_path}" unless metadata.is_a?(Hash)

      value = metadata['provider']
      raise "Vagrant metadata provider must be a non-empty string: #{metadata_path}" unless value.is_a?(String) && !value.empty?

      value
    rescue JSON::ParserError => error
      raise "Vagrant metadata is not valid JSON: #{metadata_path}: #{error.message}"
    end

    def staging_path(artifact_directory, operation)
      parent = File.dirname(artifact_directory)
      basename = File.basename(artifact_directory)
      File.join(parent, ".#{basename}.vagrant-box-#{operation}-#{Process.pid}")
    end

    def with_staging(artifact_directory, operation)
      staging = staging_path(artifact_directory, operation)
      raise "staging directory already exists: #{staging}" if File.exist?(staging)

      Dir.mkdir(staging)
      yield staging
    ensure
      FileUtils.rm_rf(staging) if staging && File.exist?(staging)
    end

    def extract_box(box, image)
      FileUtils.mkdir_p(image)
      run_command(ARCHIVE_COMMAND, '-xf', box, '-C', image)
    end

    def package_box(image, box, compression: nil)
      entries = Dir.children(image).sort
      raise "Vagrant image is empty: #{image}" if entries.empty?

      FileUtils.mkdir_p(File.dirname(box))
      arguments = [ARCHIVE_COMMAND, '-cf', box]
      arguments.concat(['--use-compress-program', compression]) unless compression.nil?
      run_command(*arguments, *entries, chdir: image)
    end

    def measure_elapsed_seconds
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    end

    def directory_size(directory)
      Dir.glob(File.join(directory, '**', '*'), File::FNM_DOTMATCH).sum do |path|
        File.file?(path) ? File.size(path) : 0
      end
    end

    def correct_hyperv(image)
      virtual_machines = File.join(image, 'Virtual Machines')
      require_directory(virtual_machines, 'Hyper-V Virtual Machines directory')
      box_xml = File.join(virtual_machines, 'box.xml')
      require_file(box_xml, 'Hyper-V box.xml')
      configurations = Dir.children(virtual_machines).select do |entry|
        File.extname(entry).downcase == '.vmcx' && File.file?(File.join(virtual_machines, entry))
      end
      unless configurations.length == 1
        raise "Hyper-V box must contain exactly one .vmcx directly under #{virtual_machines}; found #{configurations.length}"
      end

      File.delete(box_xml)
    end

    def promote_directories(artifact_directory, staging, names)
      backup = staging_path(artifact_directory, 'backup')
      raise "backup directory already exists: #{backup}" if File.exist?(backup)

      Dir.mkdir(backup)
      backed_up = []
      promoted = []
      preserve_backup = false
      begin
        names.each do |name|
          source = File.join(staging, name)
          destination = File.join(artifact_directory, name)
          previous = File.join(backup, name)
          if File.exist?(destination)
            File.rename(destination, previous)
            backed_up << [destination, previous]
          end
          File.rename(source, destination)
          promoted << destination
        end
      rescue StandardError => error
        rollback_errors = []
        promoted.reverse_each do |destination|
          FileUtils.rm_rf(destination)
        rescue StandardError => rollback_error
          rollback_errors << rollback_error
        end
        backed_up.reverse_each do |destination, previous|
          File.rename(previous, destination)
        rescue StandardError => rollback_error
          rollback_errors << rollback_error
        end
        unless rollback_errors.empty?
          preserve_backup = true
          raise "#{error.message}\nrollback failed: #{rollback_errors.map(&:message).join('; ')}\noriginal artifacts remain recoverable in #{backup}"
        end
        raise
      ensure
        FileUtils.rm_rf(backup) if File.exist?(backup) && !preserve_backup
      end
    end

    def prepare(artifact_directory)
      artifact_directory = File.expand_path(artifact_directory)
      require_directory(artifact_directory, 'artifact directory')
      source_box = File.join(artifact_directory, BOX_PATH)
      require_file(source_box, 'Packer Vagrant box')
      validate_tool(ARCHIVE_COMMAND, 'tar implementation')
      input_size = File.size(source_box)

      selected_provider = nil
      extraction_duration = nil
      packaging_duration = nil
      with_staging(artifact_directory, 'prepare') do |staging|
        image = File.join(staging, IMAGE_PATH)
        extraction_duration = measure_elapsed_seconds { extract_box(source_box, image) }
        selected_provider = provider(image)
        correct_hyperv(image) if selected_provider == 'hyperv'
        packaging_duration = measure_elapsed_seconds { package_box(image, File.join(staging, BOX_PATH)) }
        promote_directories(artifact_directory, staging, [IMAGE_PATH, 'vagrant'])
      end
      output_box = File.join(artifact_directory, BOX_PATH)
      puts JSON.generate(
        operation: 'prepare',
        artifact_directory: artifact_directory,
        provider: selected_provider,
        input_size_bytes: input_size,
        extraction_duration_seconds: extraction_duration,
        packaging_duration_seconds: packaging_duration,
        output_size_bytes: File.size(output_box),
        outcome: 'passed'
      )
    end

    def restore(artifact_directory)
      artifact_directory = File.expand_path(artifact_directory)
      require_directory(artifact_directory, 'artifact directory')
      image = File.join(artifact_directory, IMAGE_PATH)
      require_directory(image, 'Vagrant image')
      selected_provider = provider(image)
      validate_tool(ARCHIVE_COMMAND, 'tar implementation')
      validate_tool(PIGZ_COMMAND, 'pigz parallel gzip compressor')

      compression_duration = nil
      with_staging(artifact_directory, 'restore') do |staging|
        compression_duration = measure_elapsed_seconds { package_box(image, File.join(staging, BOX_PATH), compression: PIGZ_COMMAND) }
        promote_directories(artifact_directory, staging, ['vagrant'])
      end
      output_box = File.join(artifact_directory, BOX_PATH)
      puts JSON.generate(
        operation: 'restore',
        artifact_directory: artifact_directory,
        provider: selected_provider,
        input_size_bytes: directory_size(image),
        compression_duration_seconds: compression_duration,
        output_size_bytes: File.size(output_box),
        outcome: 'passed'
      )
    end

    def run(arguments)
      command, *command_arguments = arguments
      case [command, command_arguments.length]
      when ['prepare', 1]
        prepare(command_arguments.first)
      when ['restore', 1]
        restore(command_arguments.first)
      else
        warn 'usage: vagrant_box.rb prepare <artifact-directory> | restore <artifact-directory>'
        return 1
      end
      0
    rescue StandardError => error
      warn error.message
      1
    end
  end
end

exit ArtifactTransfer::VagrantBox.run(ARGV)
