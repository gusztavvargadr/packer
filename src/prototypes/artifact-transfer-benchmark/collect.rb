#!/usr/bin/env ruby
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Metrics/AbcSize, Metrics/BlockLength, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Style/MultilineBlockChain

require 'csv'
require 'fileutils'
require 'json'
require 'net/http'
require 'optparse'
require 'time'
require 'uri'

BASE_URL = 'https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds'

def fetch(uri, json: true)
  response = Net::HTTP.get_response(URI(uri))
  raise "GET #{uri} returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  json ? JSON.parse(response.body) : response.body
end

def api(build_id, suffix)
  "#{BASE_URL}/#{build_id}/#{suffix}?api-version=7.1"
end

def stripped_lines(log)
  log.lines.map { |line| line.sub(/^\d{4}-\d\d-\d\dT\S+Z /, '').strip }
end

def json_values(log)
  stripped_lines(log).each_with_object([]) do |line, values|
    next unless line.start_with?('{')

    values << JSON.parse(line)
  rescue JSON::ParserError
    next
  end
end

def snapshots(log)
  json_values(log).select { |value| value['schema'] == 'artifact-transfer-benchmark/snapshot/v1' }
end

def numeric_field(lines, name)
  line = lines.find { |candidate| candidate.start_with?("#{name}:") }
  return if line.nil?

  value = line.split(':', 2).last.strip
  match = value.match(/\A([\d,.]+) MB\z/)
  return { 'display' => value, 'megabytes' => match[1].delete(',').to_f } unless match.nil?

  integer = value.delete(',')
  integer.match?(/\A\d+\z/) ? integer.to_i : value
end

def task_statistics(log)
  lines = stripped_lines(log)
  names = [
    'DomainId', 'Hashtype', 'Total Content', 'Physical Content Uploaded', 'Logical Content Uploaded',
    'Compression Saved', 'Deduplication Saved', 'Number of Chunks Uploaded', 'Total Number of Chunks',
    'Physical Content Downloaded', 'Local Caching Saved', 'Chunks Downloaded', 'Nodes Downloaded'
  ]
  values = names.to_h { |name| [name.downcase.tr(' ', '_'), numeric_field(lines, name)] }.compact
  version = lines.find { |line| line.start_with?('Version      :') }&.split(':', 2)&.last&.strip
  artifact = lines.each_with_object([]) do |line, values|
    value = line[/Associated artifact (\d+) with build/, 1]
    values << value unless value.nil?
  end.last
  values.merge('task_version' => version, 'artifact_id' => artifact).compact
end

def log_warnings(log)
  lines = stripped_lines(log).select { |line| line.match?(/##\[warning\]|\bretr(?:y|ies|ying)\b/i) }.uniq
  { 'lines' => lines.first(50), 'truncated' => lines.length > 50 }
end

def configuration_from_job(name)
  name.sub(/\A(?:Build|Verify) /, '').sub(/ handoff\z/, '')
end

def operation_delta(before, after)
  return if before.nil? || after.nil?

  frequency = before.fetch('monotonic_frequency').to_f
  cpu_delta = before.fetch('cpu', {}).each_with_object({}) do |(name, value), values|
    after_value = after.fetch('cpu', {})[name]
    values[name] = after_value - value if value.is_a?(Numeric) && after_value.is_a?(Numeric)
  end
  {
    'wall_seconds' => (after.fetch('monotonic_timestamp') - before.fetch('monotonic_timestamp')) / frequency,
    'nic_received_bytes' => after.dig('network', 'received_bytes') - before.dig('network', 'received_bytes'),
    'nic_sent_bytes' => after.dig('network', 'sent_bytes') - before.dig('network', 'sent_bytes'),
    'drive_free_bytes_change' => after.dig('drive', 'free_bytes') - before.dig('drive', 'free_bytes'),
    'artifact_logical_bytes_before' => before.dig('artifact', 'logical_bytes'),
    'artifact_logical_bytes_after' => after.dig('artifact', 'logical_bytes'),
    'cpu_before' => before['cpu'],
    'cpu_after' => after['cpu'],
    'cpu_delta' => cpu_delta
  }
end

def collect_build(build_id)
  build = fetch(api(build_id, ''))
  timeline = fetch(api(build_id, 'timeline'))
  artifacts = fetch(api(build_id, 'artifacts'))
  records = timeline.fetch('records')
  by_id = records.to_h { |record| [record['id'], record] }
  relevant = records.select { |record| record['type'] == 'Task' && !record.dig('log', 'id').nil? }
  logs = relevant.to_h do |record|
    log_id = record.dig('log', 'id')
    [record['id'], fetch(api(build_id, "logs/#{log_id}"), json: false)]
  end

  grouped_snapshots = Hash.new { |hash, key| hash[key] = {} }
  relevant.each do |record|
    parent = by_id[record['parentId']]
    snapshots(logs.fetch(record['id'])).each do |snapshot|
      next unless snapshot['schema'] == 'artifact-transfer-benchmark/snapshot/v1'

      grouped_snapshots[[parent['id'], snapshot['operation']]][snapshot['phase']] = snapshot
    end
  end

  operations = grouped_snapshots.map do |(job_id, operation), phases|
    job = by_id.fetch(job_id)
    service_task = relevant.find do |record|
      next false unless record['parentId'] == job_id

      if operation == 'upload'
        record['name'].match?(/Publish (candidate )?artifacts/)
      else
        operation == 'download' && record['name'] == 'Download benchmark artifacts'
      end
    end
    before = phases['before']
    after = phases['after'] || phases['complete']
    {
      'job' => job['name'],
      'configuration' => configuration_from_job(job['name']),
      'agent' => job['workerName'],
      'operation' => operation,
      'representation' => (before || after)&.fetch('representation', nil),
      'sequence' => (before || after)&.fetch('sequence', nil),
      'before' => before,
      'after' => after,
      'delta' => operation_delta(before, after),
      'service_task' => if service_task.nil?
                          nil
                        else
                          {
                            'name' => service_task['name'],
                            'start_time' => service_task['startTime'],
                            'finish_time' => service_task['finishTime'],
                            'wall_seconds' => Time.parse(service_task['finishTime']) - Time.parse(service_task['startTime']),
                            'statistics' => task_statistics(logs.fetch(service_task['id'])),
                            'issues' => service_task['issues'] || [],
                            'warnings_and_retries' => log_warnings(logs.fetch(service_task['id']))
                          }
                        end
    }
  end

  handoffs = operations.each_with_object([]) do |upload, values|
    next unless upload['operation'] == 'upload' && !upload['before'].nil?

    transformation = operations.find do |operation|
      operation['operation'] == 'transform' && operation['configuration'] == upload['configuration'] &&
        operation['representation'] == upload['representation'] && operation['sequence'] == upload['sequence']
    end
    verification = operations.find do |operation|
      operation['operation'] == 'verify' && operation['configuration'] == upload['configuration'] &&
        operation['representation'] == upload['representation'] && operation['sequence'] == upload['sequence']
    end
    next if verification.nil? || verification['after'].nil?

    ready = transformation&.fetch('before', nil) || upload['before']
    components = %w[transform upload download reconstruct verify].each_with_object([]) do |operation_name, component_values|
      operation = operations.find do |candidate|
        candidate['operation'] == operation_name && candidate['configuration'] == upload['configuration'] &&
          candidate['representation'] == upload['representation'] && candidate['sequence'] == upload['sequence']
      end
      next if operation.nil?

      seconds = operation.dig('service_task', 'wall_seconds') || operation.dig('delta', 'wall_seconds')
      component_values << { 'operation' => operation_name, 'wall_seconds' => seconds } unless seconds.nil?
    end
    values << {
      'configuration' => upload['configuration'],
      'representation' => upload['representation'],
      'sequence' => upload['sequence'],
      'tested_artifact_ready_utc' => ready['timestamp_utc'],
      'verification_complete_utc' => verification.dig('after', 'timestamp_utc'),
      'observed_cross_job_wall_seconds' => Time.parse(verification.dig('after', 'timestamp_utc')) - Time.parse(ready['timestamp_utc']),
      'measured_component_wall_seconds' => components.sum { |component| component['wall_seconds'] },
      'components' => components,
      'upload_job' => upload['job'],
      'verify_job' => verification['job']
    }
  end

  evidence = relevant.flat_map do |record|
    parent = by_id[record['parentId']]
    json_values(logs.fetch(record['id'])).reject do |value|
      value['schema'] == 'artifact-transfer-benchmark/snapshot/v1'
    end.map do |value|
      { 'job' => parent['name'], 'task' => record['name'], 'value' => value }
    end
  end
  gates = records.select do |record|
    record['type'] == 'Task' && record['name'].match?(/\A(Build|Test|Produce canonical|Remove Hyper-V|Prepare raw-tar|Reconstruct|Verify)/)
  end.map do |record|
    parent = by_id[record['parentId']]
    { 'job' => parent['name'], 'task' => record['name'], 'result' => record['result'],
      'start_time' => record['startTime'], 'finish_time' => record['finishTime'] }
  end

  {
    'build' => {
      'id' => build['id'],
      'number' => build['buildNumber'],
      'definition_id' => build.dig('definition', 'id'),
      'definition' => build.dig('definition', 'name'),
      'branch' => build['sourceBranch'],
      'commit' => build['sourceVersion'],
      'result' => build['result'],
      'queue_time' => build['queueTime'],
      'start_time' => build['startTime'],
      'finish_time' => build['finishTime'],
      'template_parameters' => build['templateParameters'],
      'url' => build.dig('_links', 'web', 'href')
    },
    'artifacts' => artifacts.fetch('value').map do |artifact|
      {
        'name' => artifact['name'],
        'artifact_id' => artifact['id'],
        'exact_bytes' => artifact.dig('resource', 'properties', 'artifactsize')&.to_i,
        'resource' => artifact['resource']&.slice('type', 'data', 'url', 'properties')
      }
    end,
    'operations' => operations,
    'handoffs' => handoffs,
    'gates' => gates,
    'evidence' => evidence,
    'issues' => records.each_with_object([]) do |record, values|
      next if record.fetch('issues', []).empty?

      values << { 'job' => by_id[record['parentId']]&.fetch('name', nil), 'task' => record['name'], 'issues' => record['issues'] }
    end
  }
end

options = { output: 'artifact-transfer-benchmark.json' }
OptionParser.new do |parser|
  parser.banner = 'usage: ruby collect.rb [--output DATASET.json] BUILD_ID [BUILD_ID ...]'
  parser.on('--output PATH') { |path| options[:output] = path }
end.parse!
abort 'at least one build id is required' if ARGV.empty?

dataset = {
  'schema' => 'artifact-transfer-benchmark/dataset/v1',
  'collected_at_utc' => Time.now.utc.iso8601,
  'builds' => ARGV.map { |build_id| collect_build(Integer(build_id, 10)) }
}
FileUtils.mkdir_p(File.dirname(File.expand_path(options[:output])))
File.write(options[:output], "#{JSON.pretty_generate(dataset)}\n")

csv_path = options[:output].sub(/\.json\z/, '.csv')
CSV.open(csv_path, 'w') do |csv|
  csv << %w[build_id definition configuration job representation sequence operation agent wall_seconds
            observed_cross_job_wall_seconds nic_sent_bytes nic_received_bytes physical_upload_mb logical_upload_mb physical_download_mb]
  dataset['builds'].each do |entry|
    entry['operations'].each do |operation|
      statistics = operation.dig('service_task', 'statistics') || {}
      csv << [
        entry.dig('build', 'id'), entry.dig('build', 'definition'), operation['configuration'], operation['job'], operation['representation'],
        operation['sequence'], operation['operation'], operation['agent'], operation.dig('delta', 'wall_seconds'),
        nil, operation.dig('delta', 'nic_sent_bytes'), operation.dig('delta', 'nic_received_bytes'),
        statistics.dig('physical_content_uploaded', 'megabytes'), statistics.dig('logical_content_uploaded', 'megabytes'),
        statistics.dig('physical_content_downloaded', 'megabytes')
      ]
    end
    entry['handoffs'].each do |handoff|
      csv << [
        entry.dig('build', 'id'), entry.dig('build', 'definition'), handoff['configuration'],
        "#{handoff['upload_job']} -> #{handoff['verify_job']}", handoff['representation'], handoff['sequence'],
        'full_handoff', nil, handoff['measured_component_wall_seconds'], handoff['observed_cross_job_wall_seconds'], nil, nil, nil, nil, nil
      ]
    end
  end
end

puts options[:output]
puts csv_path

# rubocop:enable Layout/LineLength, Metrics/AbcSize, Metrics/BlockLength, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Style/MultilineBlockChain
