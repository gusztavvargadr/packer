require 'cgi'
require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'

SCHEMA = 'artifact-transfer/virtualbox-native/v2'.freeze
VIRTUALBOX_MANIFEST_FILENAME = 'virtualbox-manifest.json'.freeze
MIB = 1024 * 1024
CAPACITY_MARGIN = 64 * MIB

def emit(event, state = {})
  puts JSON.generate({ event: event }.merge(state))
end

def run_command(*arguments, allow_failure: false)
  stdout, stderr, status = Open3.capture3(*arguments)
  return [stdout, stderr, status] if status.success? || allow_failure

  raise "#{arguments.join(' ')} failed (#{status.exitstatus}):\n#{stdout}#{stderr}"
end

def vbox(*arguments, allow_failure: false)
  run_command(ENV.fetch('VBOXMANAGE', 'VBoxManage'), *arguments, allow_failure: allow_failure)
end

def parse_machine_readable(output)
  output.lines.each_with_object({}) do |line, result|
    key, value = line.strip.split('=', 2)
    next if value.nil?

    key = JSON.parse(key) if key.start_with?('"')
    value = JSON.parse(value) if value.start_with?('"')
    result[key] = value
  rescue JSON::ParserError
    result[key] = value
  end
end

def machine_state(vm_name)
  output, = vbox('showvminfo', vm_name, '--machinereadable')
  values = parse_machine_readable(output)
  raise "#{vm_name} is not powered off" unless values['VMState'] == 'poweroff'

  controllers = values.each_with_object([]) do |(key, value), result|
    match = key.match(/\Astoragecontrollername(\d+)\z/)
    result << [match[1], value] if match
  end.to_h
  attachments = values.each_with_object([]) do |(key, value), result|
    match = key.match(/\A(.+)-(\d+)-(\d+)\z/)
    next unless match && !match[1].include?('-') && value != 'none' && File.file?(value)
    next unless controllers.value?(match[1])

    controller = match[1]
    port = match[2]
    device = match[3]
    result << {
      controller: controller,
      port: port,
      device: device,
      path: value,
      hotpluggable: values.fetch("#{controller}-hot-pluggable-#{port}-#{device}", 'off'),
      nonrotational: values.fetch("#{controller}-nonrotational-#{port}-#{device}", 'off'),
      discard: values.fetch("#{controller}-discard-#{port}-#{device}", 'off')
    }
  end
  raise "expected exactly one attached disk in #{vm_name}, found #{attachments.length}" unless attachments.length == 1
  attachment = attachments.first
  raise "only a SATA primary disk is supported, found #{attachment[:controller]}" unless attachment[:controller] == 'SATA'
  raise 'expected the primary disk at SATA port 0 device 0' unless attachment.values_at(:port, :device) == %w[0 0]
  raise "NVRAM is missing for #{vm_name}" unless File.file?(values['NvramFile'])

  {
    name: values.fetch('name'),
    uuid: values.fetch('UUID'),
    config_file: values.fetch('CfgFile'),
    nvram_file: values.fetch('NvramFile'),
    attachment: attachment
  }
end

def medium_state(path)
  output, = vbox('showmediuminfo', 'disk', path)
  values = output.lines.each_with_object({}) do |line, result|
    next unless line.include?(':')

    key, value = line.split(':', 2)
    result[key.strip] = value.strip
  end
  capacity = values.fetch('Capacity').match(/\A([0-9]+) (K|M|G|T)Bytes\z/)
  raise "could not parse disk capacity for #{path}" if capacity.nil?
  multiplier = { 'K' => 1024, 'M' => MIB, 'G' => MIB * 1024, 'T' => MIB * 1024 * 1024 }.fetch(capacity[2])
  {
    uuid: values.fetch('UUID'),
    location: values.fetch('Location'),
    format: values.fetch('Storage format'),
    format_variant: values.fetch('Format variant'),
    capacity_bytes: Integer(capacity[1], 10) * multiplier,
    size_on_disk: values.fetch('Size on disk')
  }
end

def monolithic_sparse_medium(path)
  state = medium_state(path)
  unless state[:format] == 'VMDK' && state[:format_variant] == 'dynamic default'
    raise "expected monolithic-sparse VMDK, found #{state[:format]} #{state[:format_variant]}"
  end
  state
end

def allocated_bytes(path)
  return 0 unless File.exist?(path)

  output, = run_command('du', '-sk', path)
  Integer(output.split.first, 10) * 1024
end

def free_bytes(path)
  output, = run_command('df', '-Pk', path)
  Integer(output.lines.last.split[3], 10) * 1024
end

def file_identity(root, filename)
  {
    path: filename.delete_prefix("#{root}#{File::SEPARATOR}"),
    bytes: File.size(filename),
    sha256: Digest::SHA256.file(filename).hexdigest
  }
end

def canonical_files(image)
  Dir.glob(File.join(image, '**', '*')).select { |path| File.file?(path) }.sort
end

def detach(vm_name, attachment)
  vbox('storageattach', vm_name, '--storagectl', attachment.fetch(:controller), '--port', attachment.fetch(:port), '--device', attachment.fetch(:device), '--type', 'hdd', '--medium', 'none')
end

def attach(vm_name, attachment)
  vbox(
    'storageattach', vm_name,
    '--storagectl', attachment.fetch(:controller),
    '--port', attachment.fetch(:port),
    '--device', attachment.fetch(:device),
    '--type', 'hdd',
    '--medium', attachment.fetch(:path),
    '--hotpluggable', attachment.fetch(:hotpluggable),
    '--nonrotational', attachment.fetch(:nonrotational),
    '--discard', attachment.fetch(:discard)
  )
end

def insert_once(contents, marker, addition)
  count = contents.scan(marker).length
  raise "expected one #{marker.inspect} in metadata-only OVF, found #{count}" unless count == 1

  contents.sub(marker, "#{addition}#{marker}")
end

def patch_ovf(path, attachment, disk)
  contents = File.binread(path)
  basename = CGI.escapeHTML(File.basename(disk.fetch(:location)))
  uuid = CGI.escapeHTML(disk.fetch(:uuid))
  file_id = 'file-canonical-disk'
  disk_id = 'vmdisk-canonical'
  contents = insert_once(contents, '  </References>', "    <File ovf:id=\"#{file_id}\" ovf:href=\"#{basename}\"/>\n")

  disk_info = '    <Info>List of the virtual disks used in the package</Info>'
  raise 'expected one disk-section info element in metadata-only OVF' unless contents.scan("#{disk_info}\n").length == 1
  disk_entry = "    <Disk ovf:capacity=\"#{disk.fetch(:capacity_bytes)}\" ovf:diskId=\"#{disk_id}\" ovf:fileRef=\"#{file_id}\" ovf:format=\"http://www.vmware.com/interfaces/specifications/vmdk.html#sparse\" vbox:uuid=\"#{uuid}\"/>\n"
  contents = contents.sub("#{disk_info}\n", "#{disk_info}\n#{disk_entry}")

  controller_pattern = /      <Item>\n(?:(?!      <\/Item>).)*?<rasd:ResourceType>20<\/rasd:ResourceType>\n      <\/Item>/m
  controllers = contents.scan(controller_pattern)
  raise "expected one SATA controller item in metadata-only OVF, found #{controllers.length}" unless controllers.length == 1
  controller = controllers.first
  parent = controller[/<rasd:InstanceID>(\d+)<\/rasd:InstanceID>/, 1]
  raise 'SATA controller has no instance id' if parent.nil?
  instance = contents.scan(/<rasd:InstanceID>(\d+)<\/rasd:InstanceID>/).flatten.map(&:to_i).max + 1
  disk_item = <<~XML.lines.map { |line| "      #{line}" }.join.chomp
    <Item>
      <rasd:AddressOnParent>#{attachment.fetch(:port)}</rasd:AddressOnParent>
      <rasd:Caption>disk1</rasd:Caption>
      <rasd:Description>Disk Image</rasd:Description>
      <rasd:ElementName>disk1</rasd:ElementName>
      <rasd:HostResource>ovf:/disk/#{disk_id}</rasd:HostResource>
      <rasd:InstanceID>#{instance}</rasd:InstanceID>
      <rasd:Parent>#{parent}</rasd:Parent>
      <rasd:ResourceType>17</rasd:ResourceType>
    </Item>
  XML
  contents = contents.sub(controller, "#{controller}\n#{disk_item}")

  escaped_controller = Regexp.escape(CGI.escapeHTML(attachment.fetch(:controller)))
  storage_pattern = /          <StorageController name="#{escaped_controller}" ([^>]+)\/>/
  matches = contents.scan(storage_pattern)
  raise 'expected one SATA storage controller in metadata-only OVF' unless matches.length == 1
  original = contents.match(storage_pattern)[0]
  replacement = <<~XML.lines.map { |line| "          #{line}" }.join.chomp
    <StorageController name="#{CGI.escapeHTML(attachment.fetch(:controller))}" #{matches.first.first}>
      <AttachedDevice type="HardDisk" hotpluggable="#{attachment.fetch(:hotpluggable) == 'on'}" port="#{attachment.fetch(:port)}" device="#{attachment.fetch(:device)}">
        <Image uuid="{#{uuid}}"/>
      </AttachedDevice>
    </StorageController>
  XML
  File.binwrite(path, contents.sub(original, replacement))
end

def write_contract(root, machine, source_disk, canonical_disk, capacity)
  image = File.join(root, 'image')
  files = canonical_files(image).map { |filename| file_identity(root, filename) }
  raise 'canonical artifact must contain exactly one OVF, one NVRAM, and one VMDK' unless files.map { |file| File.extname(file[:path]).downcase }.sort == %w[.nvram .ovf .vmdk]
  manifest = {
    schema: SCHEMA,
    producer: {
      packer_virtualbox_plugin_version: packer_virtualbox_plugin_version,
      virtualbox_version: vbox('--version').first.strip,
      host_os: RbConfig::CONFIG['host_os'],
      host_architecture: RbConfig::CONFIG['host_cpu']
    },
    machine: machine,
    source_disk: source_disk,
    canonical_disk: canonical_disk,
    capacity: capacity,
    canonical: { files: files }
  }
  File.write(File.join(root, VIRTUALBOX_MANIFEST_FILENAME), JSON.pretty_generate(manifest) + "\n")
  manifest
end

def produce(vm_name, target, manifest: true)
  raise "target already exists: #{target}" if File.exist?(target)
  state = machine_state(vm_name)
  source_disk = medium_state(state.dig(:attachment, :path))
  unless %w[VDI VMDK].include?(source_disk[:format])
    raise "expected Packer source format VDI or VMDK, found #{source_disk[:format]}"
  end
  if source_disk[:format] == 'VMDK' && source_disk[:format_variant].include?('streamOptimized')
    raise "Packer source disk is already compressed: #{source_disk[:format_variant]}"
  end

  parent = File.dirname(File.expand_path(target))
  source_allocated = allocated_bytes(state.dig(:attachment, :path))
  required = source_allocated + CAPACITY_MARGIN
  available = free_bytes(parent)
  raise "insufficient disk capacity: require #{required} bytes, have #{available} bytes" if available < required
  capacity = { available_bytes_before: available, required_free_bytes: required, source_allocated_bytes: source_allocated }
  stage = File.join(parent, ".#{File.basename(target)}.staging-#{Process.pid}")
  raise "staging path already exists: #{stage}" if File.exist?(stage)
  image = File.join(stage, 'image')
  FileUtils.mkdir_p(image)
  vmdk = File.join(image, "#{vm_name}.vmdk")
  ovf = File.join(image, "#{vm_name}.ovf")
  detached = false
  canonical_registered = false
  begin
    vbox('clonemedium', 'disk', state.dig(:attachment, :path), vmdk, '--format', 'VMDK', '--variant', 'Standard')
    canonical_registered = true
    canonical_disk = monolithic_sparse_medium(vmdk)
    detach(vm_name, state.fetch(:attachment))
    detached = true
    emit('disk_detached', vm_name: vm_name, attachment: state.fetch(:attachment))
    vbox('export', vm_name, '--output', ovf)
  ensure
    if detached
      attach(vm_name, state.fetch(:attachment))
      raise 'failed to restore the original disk attachment' unless machine_state(vm_name).fetch(:attachment) == state.fetch(:attachment)
      emit('disk_restored', vm_name: vm_name, attachment: state.fetch(:attachment))
    end
    vbox('closemedium', 'disk', vmdk) if canonical_registered
  end
  patch_ovf(ovf, state.fetch(:attachment), canonical_disk)
  vbox('import', ovf, '--dry-run')
  FileUtils.cp(state.fetch(:nvram_file), File.join(image, File.basename(state.fetch(:nvram_file)))) unless canonical_files(image).any? { |file| File.extname(file).downcase == '.nvram' }
  extensions = canonical_files(image).map { |file| File.extname(file).downcase }.sort
  raise 'canonical artifact must contain exactly one OVF, one NVRAM, and one VMDK' unless extensions == %w[.nvram .ovf .vmdk]
  contract = write_contract(stage, state, source_disk, canonical_disk, capacity) if manifest
  File.rename(stage, target)
  emit('artifact_produced', target: target, manifest: contract)
  contract
rescue StandardError
  FileUtils.rm_rf(stage) if stage && File.exist?(stage)
  raise
end

def registered?(vm_name)
  vbox('showvminfo', vm_name, allow_failure: true).last.success?
end

def registered_vms
  vbox('list', 'vms').first.lines.each_with_object([]) do |line, result|
    encoded = line[/\A("(?:[^"\\]|\\.)*") \{/, 1]
    result << JSON.parse(encoded) unless encoded.nil?
  end
end

def find_registered_vm(image_directory)
  prefix = "#{File.expand_path(image_directory)}#{File::SEPARATOR}"
  matches = registered_vms.select do |name|
    File.expand_path(machine_state(name).dig(:attachment, :path)).start_with?(prefix)
  rescue StandardError
    false
  end
  raise "expected one registered VM backed by #{image_directory}, found #{matches.length}" unless matches.length == 1

  matches.first
end

def packer_virtualbox_plugin_version
  output, = run_command(ENV.fetch('PACKER', 'packer'), 'plugins', 'installed')
  output.scan(%r{/hashicorp/virtualbox/packer-plugin-virtualbox_v([0-9.]+)}).flatten.max
end

def prepare(artifact_root)
  artifact_root = File.expand_path(artifact_root)
  image = File.join(artifact_root, 'image')
  vm_name = find_registered_vm(image)
  canonical = File.join(artifact_root, ".virtualbox-native-#{Process.pid}")
  begin
    result = produce(vm_name, canonical)
  ensure
    vbox('unregistervm', vm_name, '--delete', allow_failure: true) if registered?(vm_name)
  end
  promoted = false
  begin
    remaining = Dir.children(image)
    raise "build-owned VM cleanup left image source files: #{remaining.join(', ')}" unless remaining.empty?
    Dir.rmdir(image)
    File.rename(File.join(canonical, 'image'), image)
    promoted = true
    FileUtils.rm_f(File.join(artifact_root, VIRTUALBOX_MANIFEST_FILENAME))
    File.rename(File.join(canonical, VIRTUALBOX_MANIFEST_FILENAME), File.join(artifact_root, VIRTUALBOX_MANIFEST_FILENAME))
    Dir.rmdir(canonical)
    emit('prepare_complete', artifact_root: artifact_root, manifest: result)
  rescue StandardError
    FileUtils.rm_rf(canonical) if File.exist?(canonical)
    if promoted
      FileUtils.rm_rf(image)
      FileUtils.rm_f(File.join(artifact_root, VIRTUALBOX_MANIFEST_FILENAME))
    end
    raise
  end
end

def prepare_vagrant(artifact_root)
  artifact_root = File.expand_path(artifact_root)
  image = File.join(artifact_root, 'image')
  vm_name = find_registered_vm(image)
  canonical = File.join(artifact_root, ".virtualbox-vagrant-#{Process.pid}")
  begin
    produce(vm_name, canonical, manifest: false)
  ensure
    vbox('unregistervm', vm_name, '--delete', allow_failure: true) if registered?(vm_name)
  end

  promoted = false
  begin
    remaining = Dir.children(image)
    raise "build-owned VM cleanup left image source files: #{remaining.join(', ')}" unless remaining.empty?
    Dir.rmdir(image)
    File.rename(File.join(canonical, 'image'), image)
    promoted = true
    Dir.rmdir(canonical)
    emit(
      'virtualbox_vagrant_inputs_complete',
      artifact_root: artifact_root,
      canonical_files: canonical_files(image).map { |path| path.delete_prefix("#{artifact_root}#{File::SEPARATOR}") }
    )
  rescue StandardError
    FileUtils.rm_rf(image) if promoted
    raise
  ensure
    FileUtils.rm_rf(canonical)
  end
end

def complete_vagrant(artifact_root)
  artifact_root = File.expand_path(artifact_root)
  image = File.join(artifact_root, 'image')
  remaining = canonical_files(image)
  raise "Vagrant post-processor left canonical inputs behind: #{remaining.join(', ')}" unless remaining.empty?

  Dir.rmdir(image) if File.directory?(image)
  emit('virtualbox_vagrant_complete', artifact_root: artifact_root)
end

command, *arguments = ARGV
case [command, arguments.length]
when ['prepare-virtualbox-native', 1]
  prepare(arguments.first)
when ['prepare-virtualbox-vagrant', 1]
  prepare_vagrant(*arguments)
when ['complete-virtualbox-vagrant', 1]
  complete_vagrant(*arguments)
else
  warn 'usage: virtualbox_native.rb prepare-virtualbox-native <artifact-directory> | prepare-virtualbox-vagrant <artifact-directory> | complete-virtualbox-vagrant <artifact-directory>'
  exit 1
end
