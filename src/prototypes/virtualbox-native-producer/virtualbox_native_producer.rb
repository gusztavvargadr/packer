require 'cgi'
require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'

SCHEMA = 'virtualbox-native/registered-ovf-monolithic-sparse/v1'.freeze
MIB = 1024 * 1024

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

  controller_names = values.each_with_object([]) do |(key, value), result|
    match = key.match(/\Astoragecontrollername(\d+)\z/)
    result << [match[1], value] if match
  end.to_h
  attachments = values.each_with_object([]) do |(key, value), result|
    match = key.match(/\A(.+)-(\d+)-(\d+)\z/)
    next unless match
    next if match[1].include?('-') || value == 'none' || !File.file?(value)
    next unless controller_names.value?(match[1])

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
  raise "expected the primary disk at SATA port 0 device 0" unless attachment.values_at(:port, :device) == %w[0 0]
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

def detach(vm_name, attachment)
  vbox(
    'storageattach', vm_name,
    '--storagectl', attachment.fetch(:controller),
    '--port', attachment.fetch(:port),
    '--device', attachment.fetch(:device),
    '--type', 'hdd',
    '--medium', 'none'
  )
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

def elapsed
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  result = yield
  [result, Process.clock_gettime(Process::CLOCK_MONOTONIC) - started]
end

def allocated_bytes(path)
  return 0 unless File.exist?(path)

  output, = run_command('du', '-sk', path)
  Integer(output.split.first, 10) * 1024
end

def file_state(root, path)
  {
    path: path.delete_prefix("#{root}#{File::SEPARATOR}"),
    logical_bytes: File.size(path),
    allocated_bytes: allocated_bytes(path),
    sha256: Digest::SHA256.file(path).hexdigest
  }
end

def artifact_state(root)
  files = Dir.glob(File.join(root, '**', '*'), File::FNM_DOTMATCH)
    .select { |path| File.file?(path) }
    .sort
    .map { |path| file_state(root, path) }
  {
    logical_bytes: files.sum { |file| file[:logical_bytes] },
    allocated_bytes: files.sum { |file| file[:allocated_bytes] },
    files: files
  }
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
  capacity = disk.fetch(:capacity_bytes)
  file_id = 'file-wayfinder-disk'
  disk_id = 'vmdisk-wayfinder'

  contents = insert_once(
    contents,
    '  </References>',
    "    <File ovf:id=\"#{file_id}\" ovf:href=\"#{basename}\"/>\n"
  )
  disk_info = '    <Info>List of the virtual disks used in the package</Info>'
  disk_info_count = contents.scan("#{disk_info}\n").length
  raise "expected one disk-section info element in metadata-only OVF, found #{disk_info_count}" unless disk_info_count == 1
  contents = contents.sub(
    "#{disk_info}\n",
    "#{disk_info}\n    <Disk ovf:capacity=\"#{capacity}\" ovf:diskId=\"#{disk_id}\" ovf:fileRef=\"#{file_id}\" ovf:format=\"http://www.vmware.com/interfaces/specifications/vmdk.html#sparse\" vbox:uuid=\"#{uuid}\"/>\n"
  )

  controller_pattern = /      <Item>\n(?:(?!      <\/Item>).)*?<rasd:ResourceType>20<\/rasd:ResourceType>\n      <\/Item>/m
  controllers = contents.scan(controller_pattern)
  raise "expected one SATA controller item in metadata-only OVF, found #{controllers.length}" unless controllers.length == 1
  controller_item = controllers.first
  controller_instance = controller_item[/<rasd:InstanceID>(\d+)<\/rasd:InstanceID>/, 1]
  raise 'SATA controller has no instance id' if controller_instance.nil?
  disk_instance = contents.scan(/<rasd:InstanceID>(\d+)<\/rasd:InstanceID>/).flatten.map(&:to_i).max + 1
  disk_item = <<~XML.lines.map { |line| "      #{line}" }.join
    <Item>
      <rasd:AddressOnParent>#{attachment.fetch(:port)}</rasd:AddressOnParent>
      <rasd:Caption>disk1</rasd:Caption>
      <rasd:Description>Disk Image</rasd:Description>
      <rasd:ElementName>disk1</rasd:ElementName>
      <rasd:HostResource>ovf:/disk/#{disk_id}</rasd:HostResource>
      <rasd:InstanceID>#{disk_instance}</rasd:InstanceID>
      <rasd:Parent>#{controller_instance}</rasd:Parent>
      <rasd:ResourceType>17</rasd:ResourceType>
    </Item>
  XML
  contents = contents.sub(controller_item, "#{controller_item}\n#{disk_item.chomp}")

  escaped_controller = Regexp.escape(CGI.escapeHTML(attachment.fetch(:controller)))
  storage_pattern = /          <StorageController name="#{escaped_controller}" ([^>]+)\/>/
  storage_matches = contents.scan(storage_pattern)
  raise "expected one #{attachment.fetch(:controller)} storage controller in metadata-only OVF, found #{storage_matches.length}" unless storage_matches.length == 1
  full_storage = contents.match(storage_pattern)[0]
  attributes = storage_matches.first.first
  attached_device = <<~XML.lines.map { |line| "          #{line}" }.join.chomp
    <StorageController name="#{CGI.escapeHTML(attachment.fetch(:controller))}" #{attributes}>
      <AttachedDevice type="HardDisk" hotpluggable="#{attachment.fetch(:hotpluggable) == 'on'}" port="#{attachment.fetch(:port)}" device="#{attachment.fetch(:device)}">
        <Image uuid="{#{uuid}}"/>
      </AttachedDevice>
    </StorageController>
  XML
  contents = contents.sub(full_storage, attached_device)
  File.binwrite(path, contents)
end

def produce(vm_name, target, fail_after_detach: false)
  raise "target already exists: #{target}" if File.exist?(target)

  state = machine_state(vm_name)
  source_disk = medium_state(state.dig(:attachment, :path))
  raise "expected Packer's source VDI, found #{source_disk[:format]}" unless source_disk[:format] == 'VDI'

  stage = File.join(File.dirname(File.expand_path(target)), ".#{File.basename(target)}.staging-#{Process.pid}")
  raise "staging path already exists: #{stage}" if File.exist?(stage)
  image = File.join(stage, 'image')
  FileUtils.mkdir_p(image)
  vmdk = File.join(image, "#{vm_name}.vmdk")
  ovf = File.join(image, "#{vm_name}.ovf")
  peak_stage = allocated_bytes(stage)
  source_allocated = allocated_bytes(state.dig(:attachment, :path))
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  cpu_started = Process.times
  detached = false

  begin
    _, clone_seconds = elapsed do
      vbox('clonemedium', 'disk', state.dig(:attachment, :path), vmdk, '--format', 'VMDK', '--variant', 'Standard')
    end
    canonical_disk = medium_state(vmdk)
    raise "canonical disk remains compressed: #{canonical_disk[:format_variant]}" if canonical_disk[:format_variant].include?('streamOptimized')
    peak_stage = [peak_stage, allocated_bytes(stage)].max
    emit('disk_cloned', seconds: clone_seconds, source: source_disk, canonical: canonical_disk)

    detach(vm_name, state.fetch(:attachment))
    detached = true
    emit('disk_detached', vm_name: vm_name, attachment: state.fetch(:attachment))
    raise 'injected failure after detach' if fail_after_detach

    _, metadata_export_seconds = elapsed { vbox('export', vm_name, '--output', ovf) }
    peak_stage = [peak_stage, allocated_bytes(stage)].max
    emit('metadata_exported', seconds: metadata_export_seconds, ovf: ovf)
  ensure
    if detached
      attach(vm_name, state.fetch(:attachment))
      restored = machine_state(vm_name).fetch(:attachment)
      raise 'failed to restore the original disk attachment' unless restored == state.fetch(:attachment)
      emit('disk_restored', vm_name: vm_name, attachment: restored)
    end
  end

  _, rewrite_seconds = elapsed { patch_ovf(ovf, state.fetch(:attachment), canonical_disk) }
  _, dry_run_seconds = elapsed { vbox('import', ovf, '--dry-run') }
  canonical = artifact_state(image)
  cpu_finished = Process.times
  result = {
    schema: SCHEMA,
    host_os: RbConfig::CONFIG['host_os'],
    host_architecture: RbConfig::CONFIG['host_cpu'],
    packer_virtualbox_plugin_version: packer_virtualbox_plugin_version,
    virtualbox_version: vbox('--version').first.strip,
    machine: state,
    source_disk: source_disk,
    canonical_disk: canonical_disk,
    canonical: canonical,
    ovf_import_dry_run: true,
    timings: {
      clone_seconds: clone_seconds,
      metadata_export_seconds: metadata_export_seconds,
      ovf_rewrite_seconds: rewrite_seconds,
      import_dry_run_seconds: dry_run_seconds,
      total_seconds: Process.clock_gettime(Process::CLOCK_MONOTONIC) - started,
      process_user_cpu_seconds: cpu_finished.utime - cpu_started.utime,
      process_system_cpu_seconds: cpu_finished.stime - cpu_started.stime,
      child_user_cpu_seconds: cpu_finished.cutime - cpu_started.cutime,
      child_system_cpu_seconds: cpu_finished.cstime - cpu_started.cstime
    },
    peak_stage_allocated_bytes: peak_stage,
    source_allocated_bytes: source_allocated,
    peak_combined_allocated_bytes: source_allocated + peak_stage
  }
  File.write(File.join(stage, 'virtualbox-native-producer-prototype.json'), JSON.pretty_generate(result) + "\n")
  File.rename(stage, target)
  emit('artifact_produced', target: target, result: result)
  result
rescue StandardError
  FileUtils.rm_rf(stage) if stage && File.exist?(stage)
  raise
end

def fixture_iso
  return ENV.fetch('FIXTURE_ISO') if ENV.key?('FIXTURE_ISO')

  output, = vbox('list', 'systemproperties')
  path = output[/^Default Guest Additions ISO:\s+(.+)$/, 1]
  raise 'set FIXTURE_ISO to a local ISO path' if path.nil? || path.empty? || !File.file?(path)

  path
end

def registered?(vm_name)
  _, _, status = vbox('showvminfo', vm_name, allow_failure: true)
  status.success?
end

def registered_vms
  output, = vbox('list', 'vms')
  output.lines.map do |line|
    encoded_name = line[/\A("(?:[^"\\]|\\.)*") \{/, 1]
    JSON.parse(encoded_name) unless encoded_name.nil?
  end.compact
end

def find_registered_vm(image_directory)
  prefix = "#{File.expand_path(image_directory)}#{File::SEPARATOR}"
  matches = registered_vms.select do |vm_name|
    state = machine_state(vm_name)
    File.expand_path(state.dig(:attachment, :path)).start_with?(prefix)
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

def write_canonical_checksum(artifact_root)
  files = Dir.glob(File.join(artifact_root, 'image', '**', '*')).select { |path| File.file?(path) }.sort
  lines = files.map do |path|
    relative = path.delete_prefix("#{artifact_root}#{File::SEPARATOR}")
    "#{Digest::SHA256.file(path).hexdigest}\t#{relative}"
  end
  File.write(File.join(artifact_root, 'checksum.sha256'), lines.join("\n") + "\n")
end

def run_representative(artifact_root)
  artifact_root = File.expand_path(artifact_root)
  image = File.join(artifact_root, 'image')
  vm_name = find_registered_vm(image)
  canonical = File.join(artifact_root, ".virtualbox-native-producer-#{Process.pid}")

  begin
    result = produce(vm_name, canonical)
  ensure
    vbox('unregistervm', vm_name, '--delete', allow_failure: true) if registered?(vm_name)
  end

  remaining = Dir.children(image)
  raise "source image directory was not empty after VM cleanup: #{remaining.join(', ')}" unless remaining.empty?
  Dir.rmdir(image)
  File.rename(File.join(canonical, 'image'), image)
  FileUtils.rm_f(File.join(artifact_root, 'manifest.json'))
  FileUtils.rm_f(File.join(artifact_root, 'checksum.sha256'))
  File.rename(
    File.join(canonical, 'virtualbox-native-producer-prototype.json'),
    File.join(artifact_root, 'virtualbox-native-producer-prototype.json')
  )
  Dir.rmdir(canonical)
  write_canonical_checksum(artifact_root)
  emit('representative_complete', artifact_root: artifact_root, result: result)
end

def packer_build(template, vm_name, output, fail_build:)
  arm64 = RbConfig::CONFIG['host_cpu'].match?(/arm|aarch64/i)
  run_command(
    ENV.fetch('PACKER', 'packer'), 'build', '-color=false',
    '-var', "arm64=#{arm64}",
    '-var', "fail_build=#{fail_build}",
    '-var', "iso_url=#{fixture_iso}",
    '-var', "output_directory=#{output}",
    '-var', "vm_name=#{vm_name}",
    template,
    allow_failure: fail_build
  )
end

def verify_real_import(ovf, vm_name)
  imported_name = "#{vm_name}-import"
  begin
    vbox('import', ovf, '--vsys', '0', '--vmname', imported_name)
    vbox('startvm', imported_name, '--type', 'headless')
    sleep 1
    vbox('controlvm', imported_name, 'poweroff')
    emit('real_import_booted', vm_name: imported_name)
  ensure
    vbox('unregistervm', imported_name, '--delete', allow_failure: true) if registered?(imported_name)
  end
end

def run_fixture(target)
  raise "target already exists: #{target}" if File.exist?(target)

  template = File.expand_path('fixture.pkr.hcl', __dir__)
  root = Dir.mktmpdir('wayfinder-vbox-producer-')
  suffix = "#{Process.pid}-#{Time.now.to_i}"
  failed_vm = "wayfinder-vbox-producer-failure-#{suffix}"
  failed_output = File.join(root, 'packer-failure')
  vm_name = "wayfinder-vbox-producer-fixture-#{suffix}"
  artifact_root = File.join(root, 'artifact')
  packer_output = File.join(artifact_root, 'image')

  begin
    _, _, failed_status = packer_build(template, failed_vm, failed_output, fail_build: true)
    raise 'injected Packer failure unexpectedly succeeded' if failed_status.success?
    raise 'Packer left its failed VM registered' if registered?(failed_vm)
    raise 'Packer left its failed output directory behind' if File.exist?(failed_output)
    emit('packer_failure_cleanup_verified', vm_name: failed_vm)

    packer_build(template, vm_name, packer_output, fail_build: false)
    raise 'Packer did not leave its successful VM registered' unless registered?(vm_name)
    raise 'skip_export unexpectedly emitted an OVF' unless Dir.glob(File.join(packer_output, '*.ovf')).empty?
    emit('packer_handoff_verified', vm_name: vm_name, output: packer_output)

    failure_target = "#{target}.injected-failure"
    begin
      produce(vm_name, failure_target, fail_after_detach: true)
      raise 'producer failure injection unexpectedly succeeded'
    rescue RuntimeError => error
      raise unless error.message == 'injected failure after detach'
    end
    raise 'producer left its injected-failure target behind' if File.exist?(failure_target)
    machine_state(vm_name)
    emit('producer_failure_cleanup_verified', vm_name: vm_name)

    run_representative(artifact_root)
    ovf = Dir.glob(File.join(artifact_root, 'image', '*.ovf')).fetch(0)
    verify_real_import(ovf, vm_name)
    File.rename(artifact_root, target)
  ensure
    vbox('unregistervm', vm_name, '--delete', allow_failure: true) if registered?(vm_name)
    vbox('unregistervm', failed_vm, '--delete', allow_failure: true) if registered?(failed_vm)
    FileUtils.rm_rf(root)
  end
  emit('fixture_complete', target: target)
end

command, *arguments = ARGV
case [command, arguments.length]
when ['produce', 2]
  produce(*arguments)
when ['fixture', 1]
  run_fixture(arguments.first)
when ['representative', 1]
  run_representative(arguments.first)
else
  warn 'usage: ruby virtualbox_native_producer.rb produce <registered-vm-name> <missing-output-directory> | fixture <missing-output-directory> | representative <native-artifact-directory>'
  exit 1
end
