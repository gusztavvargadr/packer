require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'

SCHEMA = 'virtualbox-native/ovf-monolithic-sparse/v1'.freeze

def run_command(*arguments)
  stdout, stderr, status = Open3.capture3(*arguments)
  return stdout if status.success?

  raise "#{arguments.join(' ')} failed (#{status.exitstatus}):\n#{stdout}#{stderr}"
end

def vbox(*arguments)
  run_command(ENV.fetch('VBOXMANAGE', 'VBoxManage'), *arguments)
end

def image_directory(root)
  raise "#{root} is not a directory" unless Dir.exist?(root)

  candidate = File.join(root, 'image')
  Dir.exist?(candidate) ? candidate : root
end

def appliance_files(image)
  ovfs = Dir.glob(File.join(image, '*.ovf'))
  vmdks = Dir.glob(File.join(image, '*.vmdk'))
  unless ovfs.length == 1 && vmdks.length == 1
    raise "expected one OVF and one VMDK in #{image}, found #{ovfs.length} and #{vmdks.length}"
  end

  [ovfs.first, vmdks.first]
end

def require_empty_or_missing(path)
  return unless Dir.exist?(path)
  return if Dir.empty?(path)

  raise "canonical directory must be empty: #{path}"
end

def medium_state(path)
  values = vbox('showmediuminfo', 'disk', path).lines.each_with_object({}) do |line, result|
    next unless line.include?(':')

    key, value = line.split(':', 2)
    result[key.strip] = value.strip
  end
  state = {
    uuid: values['UUID'],
    format: values['Storage format'],
    format_variant: values['Format variant'],
    capacity: values['Capacity'],
    size_on_disk: values['Size on disk']
  }
  raise "could not parse VBoxManage showmediuminfo for #{path}" if state.values_at(:uuid, :format, :format_variant).any?(&:nil?)

  state
end

def allocated_bytes(path)
  output = run_command('du', '-k', path)
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

def copy_companion_files(source, target, vmdk_name)
  Dir.children(source).sort.each do |name|
    path = File.join(source, name)
    next unless File.file?(path)
    next if name == vmdk_name

    FileUtils.cp(path, File.join(target, name), preserve: true)
  end
end

def rewrite_ovf(path, vmdk_name, canonical_uuid)
  contents = File.binread(path)
  count = contents.scan('#streamOptimized').length
  raise "expected exactly one streamOptimized OVF format in #{path}, found #{count}" unless count == 1
  raise "OVF does not reference #{vmdk_name}" unless contents.include?(%(ovf:href="#{vmdk_name}"))
  source_uuid = contents[/vbox:uuid="([0-9a-f-]+)"/i, 1]
  raise "OVF has no vbox:uuid disk identifier in #{path}" if source_uuid.nil?
  uuid_count = contents.scan(source_uuid).length
  raise "expected the OVF disk UUID at least twice in #{path}, found #{uuid_count}" unless uuid_count >= 2

  rewritten = contents.sub('#streamOptimized', '#sparse').gsub(source_uuid, canonical_uuid)
  File.binwrite(path, rewritten)
end

def import_dry_run(ovf)
  vbox('import', ovf, '--dry-run')
  true
end

def prepare(source_root, canonical_root)
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  source_image = image_directory(source_root)
  require_empty_or_missing(canonical_root)
  canonical_image = File.join(canonical_root, 'image')
  FileUtils.mkdir_p(canonical_image)

  ovf, vmdk = appliance_files(source_image)
  source_medium = medium_state(vmdk)
  unless source_medium[:format_variant].include?('streamOptimized')
    raise "source VMDK is not streamOptimized: #{source_medium[:format_variant]}"
  end

  copy_companion_files(source_image, canonical_image, File.basename(vmdk))
  canonical_vmdk = File.join(canonical_image, File.basename(vmdk))
  clone_started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  vbox('clonemedium', 'disk', vmdk, canonical_vmdk, '--format', 'VMDK', '--variant', 'Standard')
  clone_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - clone_started
  canonical_medium = medium_state(canonical_vmdk)
  if canonical_medium[:format_variant].include?('streamOptimized')
    raise "canonical VMDK remains streamOptimized: #{canonical_medium[:format_variant]}"
  end

  canonical_ovf = File.join(canonical_image, File.basename(ovf))
  rewrite_ovf(canonical_ovf, File.basename(vmdk), canonical_medium[:uuid])
  import_started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  import_dry_run(canonical_ovf)
  import_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - import_started

  result = {
    schema: SCHEMA,
    host_os: RbConfig::CONFIG['host_os'],
    host_architecture: RbConfig::CONFIG['host_cpu'],
    virtualbox_version: vbox('--version').strip,
    source: artifact_state(source_image),
    canonical: artifact_state(canonical_image),
    source_medium: source_medium,
    canonical_medium: canonical_medium,
    ovf_import_dry_run: true,
    timings: {
      clone_seconds: clone_seconds,
      import_dry_run_seconds: import_seconds,
      total_seconds: Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    }
  }
  File.write(File.join(canonical_root, 'virtualbox-native-prototype.json'), JSON.pretty_generate(result) + "\n")
  puts JSON.pretty_generate(result)
end

def verify(canonical_root)
  expected = JSON.parse(File.read(File.join(canonical_root, 'virtualbox-native-prototype.json')), symbolize_names: true)
  raise "unsupported manifest schema #{expected[:schema]}" unless expected[:schema] == SCHEMA

  canonical_image = image_directory(canonical_root)
  ovf, = appliance_files(canonical_image)
  actual = artifact_state(canonical_image)
  exact = actual[:files].map { |file| file.values_at(:path, :logical_bytes, :sha256) } ==
    expected[:canonical][:files].map { |file| file.values_at(:path, :logical_bytes, :sha256) }
  result = {
    schema: SCHEMA,
    host_os: RbConfig::CONFIG['host_os'],
    host_architecture: RbConfig::CONFIG['host_cpu'],
    virtualbox_version: vbox('--version').strip,
    canonical: actual,
    expected: expected[:canonical],
    files_exact: exact,
    ovf_import_dry_run: import_dry_run(ovf)
  }
  puts JSON.pretty_generate(result)
  raise 'canonical files differ from the manifest' unless exact
end

command, *arguments = ARGV
case [command, arguments.length]
when ['prepare', 2]
  prepare(*arguments)
when ['verify', 1]
  verify(*arguments)
else
  warn 'usage: ruby virtualbox_native.rb prepare <source-native-build-directory> <empty-canonical-native-build-directory> | verify <canonical-native-build-directory>'
  exit 1
end
