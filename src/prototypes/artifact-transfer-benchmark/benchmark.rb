#!/usr/bin/env ruby
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

require 'digest'
require 'etc'
require 'fileutils'
require 'json'
require 'open3'
require 'optparse'
require 'pathname'
require 'rbconfig'
require 'time'

def windows?
  RbConfig::CONFIG.fetch('host_os').match?(/mswin|mingw|cygwin/i)
end

def powershell_json(command)
  output, error, status = Open3.capture3('powershell.exe', '-NoProfile', '-NonInteractive', '-Command', command)
  raise "PowerShell failed: #{error}" unless status.success?

  JSON.parse(output)
end

def network_counters
  if windows?
    return powershell_json(<<~'POWERSHELL')
      $adapters = @(Get-NetAdapterStatistics | Where-Object Name -NotLike '*Loopback*')
      [ordered]@{
        received_bytes = [long](($adapters | Measure-Object -Property ReceivedBytes -Sum).Sum)
        sent_bytes = [long](($adapters | Measure-Object -Property SentBytes -Sum).Sum)
        source = 'Get-NetAdapterStatistics'
      } | ConvertTo-Json -Compress
    POWERSHELL
  end

  if File.exist?('/proc/net/dev')
    received = 0
    sent = 0
    File.readlines('/proc/net/dev').drop(2).each do |line|
      name, values = line.split(':', 2)
      next if values.nil? || name.strip == 'lo'

      fields = values.split
      received += Integer(fields[0], 10)
      sent += Integer(fields[8], 10)
    end
    return { 'received_bytes' => received, 'sent_bytes' => sent, 'source' => '/proc/net/dev' }
  end

  rows = `netstat -ibn`.lines.filter_map do |line|
    fields = line.split
    fields if line.include?('<Link#') && fields.first != 'lo0'
  end
  {
    'received_bytes' => rows.sum { |fields| Integer(fields[-5], 10) },
    'sent_bytes' => rows.sum { |fields| Integer(fields[-2], 10) },
    'source' => 'netstat -ibn'
  }
end

def cpu_counters
  if windows?
    return powershell_json(<<~'POWERSHELL')
      $cpu = Get-CimInstance -ClassName Win32_PerfRawData_PerfOS_Processor -Filter "Name='_Total'"
      [ordered]@{
        unit = '100ns_ticks'
        idle = [long]$cpu.PercentIdleTime
        processor = [long]$cpu.PercentProcessorTime
        user = [long]$cpu.PercentUserTime
        source = 'Win32_PerfRawData_PerfOS_Processor'
      } | ConvertTo-Json -Compress
    POWERSHELL
  end

  if File.exist?('/proc/stat')
    fields = File.open('/proc/stat', &:readline).split.drop(1).map { |value| Integer(value, 10) }
    names = %w[user nice system idle iowait irq softirq steal]
    return names.zip(fields).to_h.merge('unit' => 'clock_ticks', 'source' => '/proc/stat')
  end

  { 'source' => 'unavailable' }
end

def artifact_state(path)
  return { 'exists' => false, 'files' => 0, 'logical_bytes' => 0 } if path.nil? || !File.exist?(path)

  files = Dir.glob(File.join(path, '**', '*'), File::FNM_DOTMATCH).select { |entry| File.file?(entry) }
  { 'exists' => true, 'files' => files.length, 'logical_bytes' => files.sum { |entry| File.size(entry) } }
end

def drive_state(path)
  resolved = File.expand_path(path.to_s.empty? ? Dir.pwd : path)
  resolved = File.dirname(resolved) until File.exist?(resolved)
  if windows?
    root = Pathname.new(resolved).ascend.to_a.last.to_s
    drive = powershell_json(<<~POWERSHELL)
      $drive = Get-PSDrive -Name '#{root[0]}'
      [ordered]@{ root = $drive.Root; total_bytes = [long]($drive.Used + $drive.Free); free_bytes = [long]$drive.Free } | ConvertTo-Json -Compress
    POWERSHELL
    return drive
  end

  output, error, status = Open3.capture3('df', '-Pk', resolved)
  raise "df failed: #{error}" unless status.success?

  fields = output.lines.last.split
  { 'root' => fields[-1], 'total_bytes' => Integer(fields[1], 10) * 1024,
    'free_bytes' => Integer(fields[3], 10) * 1024 }
end

def snapshot(options)
  output = options.fetch(:output_path)
  value = {
    'schema' => 'artifact-transfer-benchmark/snapshot/v1',
    'operation' => options[:operation],
    'phase' => options[:phase],
    'representation' => ENV['BENCHMARK_REPRESENTATION'],
    'sequence' => ENV['BENCHMARK_SEQUENCE'],
    'timestamp_utc' => Time.now.utc.iso8601(6),
    'monotonic_timestamp' => Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond),
    'monotonic_frequency' => 1_000_000_000,
    'host' => {
      'os' => RbConfig::CONFIG.fetch('host_os'),
      'architecture' => RbConfig::CONFIG.fetch('host_cpu'),
      'machine' => ENV['COMPUTERNAME'] || ENV['HOSTNAME'],
      'processor_count' => Etc.nprocessors
    },
    'azure' => {
      'agent_id' => ENV['AGENT_ID'], 'agent_name' => ENV['AGENT_NAME'], 'agent_os' => ENV['AGENT_OS'],
      'agent_version' => ENV['AGENT_VERSION'], 'build_id' => ENV['BUILD_BUILDID'], 'build_number' => ENV['BUILD_BUILDNUMBER'],
      'source_branch' => ENV['BUILD_SOURCEBRANCH'], 'source_version' => ENV['BUILD_SOURCEVERSION'],
      'job_id' => ENV['SYSTEM_JOBID'], 'job_name' => ENV['SYSTEM_JOBDISPLAYNAME']
    },
    'network' => network_counters,
    'cpu' => cpu_counters,
    'drive' => drive_state(options[:artifact_path]),
    'artifact' => artifact_state(options[:artifact_path])
  }
  FileUtils.mkdir_p(File.dirname(output))
  File.write(output, "#{JSON.pretty_generate(value)}\n")
  puts JSON.generate(value)
end

def write_file_checksum(file, output)
  resolved = File.expand_path(file)
  value = "#{Digest::SHA256.file(resolved).hexdigest}\t#{File.basename(resolved)}"
  File.write(output, "#{value}\n")
  puts value
end

def resolve_checksum_target(artifact_path, checksum_path)
  root = Pathname.new(File.expand_path(artifact_path))
  normalized = checksum_path.tr('\\', '/')
  relative = Pathname.new(normalized).cleanpath
  if relative.absolute? || relative.to_s == '..' || relative.to_s.start_with?('../')
    raise "unsafe checksum path: #{checksum_path}"
  end

  direct = root.join(relative)
  return [direct.to_s, relative.to_s] if direct.file?

  raise "checksum target does not exist: #{checksum_path}" unless relative.dirname.to_s == '.'

  matches = Dir.glob(root.join('**', relative.basename).to_s, File::FNM_DOTMATCH).select { |path| File.file?(path) }
  raise "checksum target does not exist: #{checksum_path}" if matches.empty?
  raise "checksum target is ambiguous: #{checksum_path} matched #{matches.length} files" unless matches.one?

  target = Pathname.new(matches.first)
  [target.to_s, target.relative_path_from(root).to_s]
end

def verify_checksum(artifact_path)
  checksum = File.join(artifact_path, 'checksum.sha256')
  entries = File.readlines(checksum, chomp: true).reject { |line| line.strip.empty? }.map do |line|
    match = line.match(/\A([0-9a-fA-F]{64})[\t ]+\*?(.+)\z/) or raise "unsupported checksum line: #{line}"
    expected = match[1].downcase
    target, relative = resolve_checksum_target(artifact_path, match[2].strip)
    actual = Digest::SHA256.file(target).hexdigest
    { 'path' => relative, 'bytes' => File.size(target), 'expected_sha256' => expected, 'actual_sha256' => actual,
      'exact' => actual == expected }
  end
  raise "checksum file is empty: #{checksum}" if entries.empty?

  result = { 'schema' => 'artifact-transfer-benchmark/checksum-verification/v1', 'artifact_path' => File.expand_path(artifact_path), 'entries' => entries, 'exact' => entries.all? do |entry|
    entry['exact']
  end }
  puts JSON.generate(result)
  raise 'one or more artifact checksums did not match' unless result['exact']
end

def transfer_helper_path(path = ENV['VAGRANT_TRANSFER_HELPER'])
  raise 'VAGRANT_TRANSFER_HELPER is required' if path.nil? || path.empty?

  resolved = File.expand_path(path)
  windows? && File.extname(resolved).empty? ? "#{resolved}.exe" : resolved
end

def build_transfer_helper(options)
  tool = File.expand_path('../vagrant-transfer', __dir__)
  output = transfer_helper_path(options.fetch(:output_path))
  FileUtils.mkdir_p(File.dirname(output))
  system('go', 'test', './...', chdir: tool, exception: true)
  system('go', 'build', '-o', output, '.', chdir: tool, exception: true)
  value = {
    'schema' => 'artifact-transfer-benchmark/helper-build/v1',
    'path' => output,
    'bytes' => File.size(output),
    'sha256' => Digest::SHA256.file(output).hexdigest
  }
  puts JSON.generate(value)
end

def run_transfer(*arguments, probe_path:)
  helper = transfer_helper_path
  drive_before = drive_state(probe_path)
  minimum_free_bytes = drive_before.fetch('free_bytes')
  running = true
  sampler = Thread.new do
    while running
      sleep 0.5
      begin
        minimum_free_bytes = [minimum_free_bytes, drive_state(probe_path).fetch('free_bytes')].min
      rescue StandardError
        nil
      end
    end
  end
  before = Process.times
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  finished = nil
  status = nil
  begin
    Open3.popen2e(helper, *arguments) do |stdin, output, wait|
      stdin.close
      output.each { |line| print line }
      status = wait.value
    end
    finished = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  ensure
    running = false
    sampler.join
  end
  after = Process.times
  measurement = {
    'schema' => 'artifact-transfer-benchmark/command/v1',
    'command' => [helper, *arguments],
    'wall_seconds' => finished - started,
    'child_user_cpu_seconds' => after.cutime - before.cutime,
    'child_system_cpu_seconds' => after.cstime - before.cstime,
    'drive_free_bytes_before' => drive_before['free_bytes'],
    'minimum_drive_free_bytes' => minimum_free_bytes,
    'peak_drive_bytes_consumed' => [drive_before['free_bytes'] - minimum_free_bytes, 0].max,
    'exit_status' => status.exitstatus
  }
  puts JSON.generate(measurement)
  raise "Vagrant transfer tool failed with exit code #{status.exitstatus}" unless status.success?
end

def one_box(artifact_path)
  boxes = Dir.glob(File.join(artifact_path, '*.box'))
  raise "expected one .box under #{artifact_path}, found #{boxes.length}" unless boxes.length == 1

  boxes.first
end

def canonicalize_hyperv(options)
  box = one_box(options.fetch(:artifact_path))
  output = options.fetch(:output_path)
  FileUtils.mkdir_p(output)
  canonical = File.join(output, 'vagrant.canonical.box')
  result = File.join(output, 'hyperv-canonicalization.json')
  run_transfer('canonicalize-hyperv', box, canonical, result, probe_path: output)
  FileUtils.mv(canonical, box, force: true)
  write_file_checksum(box, File.join(options.fetch(:artifact_path), 'checksum.sha256'))
  puts JSON.generate(JSON.parse(File.read(result)))
end

def prepare_vagrant_transfer(options)
  box = one_box(options.fetch(:artifact_path))
  transfer = options.fetch(:transfer_path)
  raise "transfer path must not exist: #{transfer}" if File.exist?(transfer)

  Dir.mkdir(transfer)
  manifest = File.join(transfer, 'vagrant-transfer.json')
  run_transfer('decode', box, File.join(transfer, 'vagrant.raw.tar'), manifest,
               options.fetch(:packer_vagrant_plugin_version), probe_path: transfer)
  puts JSON.generate(JSON.parse(File.read(manifest)))
end

def reconstruct_vagrant_transfer(options)
  artifact = options.fetch(:artifact_path)
  output = options.fetch(:output_path)
  raise "reconstruction output path must not exist: #{output}" if File.exist?(output)

  Dir.mkdir(output)
  manifest_path = File.join(artifact, 'vagrant-transfer.json')
  box = File.join(output, 'vagrant.box')
  run_transfer('reconstruct-packer-writes', File.join(artifact, 'vagrant.raw.tar'), manifest_path, box,
               probe_path: output)
  manifest = JSON.parse(File.read(manifest_path))
  actual = Digest::SHA256.file(box).hexdigest
  result = { 'schema' => 'artifact-transfer-benchmark/vagrant-reconstruction/v1', 'bytes' => File.size(box),
             'expected_sha256' => manifest.dig('source', 'sha256'), 'actual_sha256' => actual, 'exact' => actual == manifest.dig('source', 'sha256') }
  puts JSON.generate(result)
  raise 'reconstructed Vagrant box checksum did not match' unless result['exact']
end

def verify_vagrant_reconstruction(options)
  artifact = options.fetch(:artifact_path)
  output = options.fetch(:output_path)
  manifest = JSON.parse(File.read(File.join(artifact, 'vagrant-transfer.json')))
  box = File.join(output, 'vagrant.box')
  actual = Digest::SHA256.file(box).hexdigest
  result = { 'schema' => 'artifact-transfer-benchmark/vagrant-verification/v1', 'bytes' => File.size(box),
             'expected_sha256' => manifest.dig('source', 'sha256'), 'actual_sha256' => actual, 'exact' => actual == manifest.dig('source', 'sha256') }
  puts JSON.generate(result)
  raise 'reconstructed Vagrant box checksum did not match' unless result['exact']
end

def verify_virtualbox(artifact_path)
  verify_checksum(artifact_path)
  ovfs = Dir.glob(File.join(artifact_path, '**', '*.ovf'))
  raise "expected one OVF under #{artifact_path}, found #{ovfs.length}" unless ovfs.length == 1

  system('VBoxManage', 'import', ovfs.first, '--dry-run', exception: true)
  puts JSON.generate({ 'schema' => 'artifact-transfer-benchmark/virtualbox-verification/v1',
                       'ovf' => File.basename(ovfs.first), 'import_dry_run' => true })
end

action = ARGV.shift or abort 'an action is required'
options = { packer_vagrant_plugin_version: '1.1.6' }
OptionParser.new do |parser|
  parser.on('--artifact-path PATH') { |value| options[:artifact_path] = value }
  parser.on('--file-path PATH') { |value| options[:file_path] = value }
  parser.on('--output-path PATH') { |value| options[:output_path] = value }
  parser.on('--operation NAME') { |value| options[:operation] = value }
  parser.on('--phase NAME') { |value| options[:phase] = value }
  parser.on('--transfer-path PATH') { |value| options[:transfer_path] = value }
  parser.on('--packer-vagrant-plugin-version VERSION') { |value| options[:packer_vagrant_plugin_version] = value }
end.parse!

case action
when 'canonicalize-hyperv' then canonicalize_hyperv(options)
when 'build-transfer-helper' then build_transfer_helper(options)
when 'prepare-vagrant-transfer' then prepare_vagrant_transfer(options)
when 'reconstruct-vagrant-transfer' then reconstruct_vagrant_transfer(options)
when 'snapshot' then snapshot(options)
when 'verify-checksum' then verify_checksum(options.fetch(:artifact_path))
when 'verify-vagrant-reconstruction' then verify_vagrant_reconstruction(options)
when 'verify-virtualbox' then verify_virtualbox(options.fetch(:artifact_path))
when 'write-file-checksum' then write_file_checksum(options.fetch(:file_path), options.fetch(:output_path))
else abort "unsupported action: #{action}"
end

# rubocop:enable Layout/LineLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
