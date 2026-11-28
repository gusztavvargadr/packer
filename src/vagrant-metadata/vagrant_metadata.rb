require 'digest'
require 'json'
require 'open3'
require 'optparse'

module VagrantMetadata
  Entry = Struct.new(:version, :provider, :architecture, :url, :checksum)

  class ConflictingEntryError < StandardError; end

  module_function

  CHECKSUM_TYPE = 'SHA256'.freeze
  ACTIVE_STATUS = 'active'.freeze

  def deep_copy(value)
    Marshal.load(Marshal.dump(value))
  end

  def new_document(name, description)
    document = { 'name' => name }
    document['description'] = description unless description.nil? || description.empty?
    document['versions'] = []
    document
  end

  def new_provider(entry)
    {
      'name' => entry.provider,
      'url' => entry.url,
      'checksum' => entry.checksum,
      'checksum_type' => CHECKSUM_TYPE,
      'architecture' => entry.architecture,
      'default_architecture' => false
    }
  end

  def version_key(version)
    version.to_s.split('.').map(&:to_i)
  end

  def same_entry?(provider, entry)
    provider['url'] == entry.url && provider['checksum'].to_s.casecmp(entry.checksum.to_s).zero?
  end

  def describe_conflict(provider, entry)
    "#{entry.version} #{entry.provider}/#{entry.architecture} is already published with " \
      "url #{provider['url']} and checksum #{provider['checksum']}, not url #{entry.url} and checksum #{entry.checksum}"
  end

  def apply_default_architecture(providers, provider_name, default_architecture)
    candidates = providers.select { |provider| provider['name'] == provider_name }
    chosen = candidates.find { |provider| provider['architecture'] == default_architecture }
    chosen ||= candidates.min_by { |provider| provider['architecture'].to_s }
    candidates.each { |provider| provider['default_architecture'] = provider.equal?(chosen) }
  end

  # Returns the merged copy of the document and whether it differs from the input.
  def merge(document, entry, name:, default_architecture:, description: nil)
    result = document.nil? ? new_document(name, description) : deep_copy(document)
    versions = (result['versions'] ||= [])

    version = versions.find { |item| item['version'] == entry.version }
    if version.nil?
      version = { 'version' => entry.version, 'status' => ACTIVE_STATUS, 'providers' => [] }
      versions << version
    end
    providers = (version['providers'] ||= [])

    existing = providers.find { |item| item['name'] == entry.provider && item['architecture'] == entry.architecture }
    unless existing.nil?
      raise ConflictingEntryError, describe_conflict(existing, entry) unless same_entry?(existing, entry)

      return [deep_copy(document), false]
    end

    providers << new_provider(entry)
    apply_default_architecture(providers, entry.provider, default_architecture)
    providers.sort_by! { |item| [item['name'].to_s, item['architecture'].to_s] }
    versions.sort! { |left, right| version_key(right['version']) <=> version_key(left['version']) }

    [result, true]
  end

  def serialize(document)
    "#{JSON.pretty_generate(document)}\n"
  end

  def read_snapshot_description(snapshot_json, box)
    snapshot = JSON.parse(snapshot_json)
    match = (snapshot['boxes'] || []).find { |item| item['name'] == box }
    description = match.nil? ? nil : match['description']
    description.nil? || description.empty? ? nil : description
  end

  def rclone_cat(path, runner: Open3.method(:capture3))
    stdout, stderr, status = runner.call('rclone', 'cat', path, binmode: true)
    raise "rclone cat #{path} failed (#{status.exitstatus}):\n#{stderr}" unless status.success?
    raise "rclone cat #{path} returned nothing; the object is missing or empty" if stdout.empty?

    stdout.force_encoding(Encoding::UTF_8)
  end

  # Reads and writes documents through rclone, with R2 enforcing the conditional writes.
  class RcloneStore
    READ_ATTEMPTS = 3
    REJECTED = /StatusCode: 412|PreconditionFailed/.freeze
    WRITE_OPTIONS = ['--streaming-upload-cutoff', '16Mi', '--retries', '1'].freeze

    def initialize(destination, runner: Open3.method(:capture3))
      @destination = destination
      @runner = runner
    end

    def path(key)
      "#{@destination}/#{key}"
    end

    # Returns nil when the object is missing, or its body with the ETag that describes that body.
    def read(key)
      READ_ATTEMPTS.times do
        info = JSON.parse(run!('lsjson', '--stat', '--hash', '--files-only', path(key)))
        return nil if info.nil?

        etag = (info['Hashes'] || {})['md5']
        raise "rclone reported no MD5 hash for #{path(key)}" if etag.nil? || etag.empty?

        body = run!('cat', path(key))
        return [body.force_encoding(Encoding::UTF_8), etag.downcase] if Digest::MD5.hexdigest(body) == etag.downcase
      end
      raise "#{path(key)} kept changing while it was read, #{READ_ATTEMPTS} times"
    end

    # Returns false only when R2 rejects the write's precondition.
    def write(key, body, etag)
      condition = etag.nil? ? 'If-None-Match: *' : %(If-Match: "#{etag}")
      arguments = ['rclone', 'rcat', path(key), '--header-upload', 'Content-Type: application/json', '--header-upload', condition] + WRITE_OPTIONS
      _stdout, stderr, status = @runner.call(*arguments, stdin_data: body, binmode: true)
      return true if status.success?
      return false if stderr =~ REJECTED

      raise "rclone rcat #{path(key)} failed (#{status.exitstatus}):\n#{stderr}"
    end

    private

    def run!(*arguments)
      stdout, stderr, status = @runner.call('rclone', *arguments, binmode: true)
      raise "rclone #{arguments.join(' ')} failed (#{status.exitstatus}):\n#{stderr}" unless status.success?

      stdout
    end
  end

  def describe_entry(entry)
    "#{entry.version} #{entry.provider}/#{entry.architecture} url #{entry.url} checksum #{entry.checksum}"
  end

  # Merges the entry into the document at the key, writing only when the document is unchanged since it was read.
  def publish(store:, key:, entry:, name:, default_architecture:, description_source:, attempts: 5, sleeper: ->(seconds) { sleep(seconds) }, log: $stdout)
    log.puts "publishing #{key}: #{describe_entry(entry)}"
    attempt = 1
    loop do
      current = store.read(key)
      if current.nil?
        log.puts "read #{key}: missing"
        document = nil
        etag = nil
        description = description_source.call
      else
        body, etag = current
        log.puts "read #{key}: etag #{etag}, before:\n#{body}"
        document = JSON.parse(body)
        description = nil
      end

      merged, changed = merge(document, entry, name: name, default_architecture: default_architecture, description: description)
      unless changed
        log.puts "#{key}: entry already present, not written"
        return :unchanged
      end

      merged_body = serialize(merged)
      log.puts "write #{key}: #{etag.nil? ? 'If-None-Match: *' : "If-Match: #{etag}"}, after:\n#{merged_body}"
      if store.write(key, merged_body, etag)
        log.puts "write #{key}: accepted"
        return etag.nil? ? :created : :updated
      end

      log.puts "write #{key}: rejected, the document changed since it was read (attempt #{attempt} of #{attempts})"
      raise "gave up publishing #{key} after #{attempts} rejected writes; rerun with the same values to finish" if attempt >= attempts

      sleeper.call(rand(1.0..4.0))
      attempt += 1
    end
  end

  PUBLISH_OPTIONS = {
    destination: 'rclone destination root of the metadata documents, such as r2:vagrant',
    author: 'box author, such as gusztavvargadr',
    box: 'box name, such as ubuntu-server-2404-lts',
    version: 'box version, such as 2610.0.0',
    provider: 'Vagrant provider, such as libvirt',
    architecture: 'guest architecture, such as amd64',
    url: 'payload URL',
    checksum: 'payload SHA256 checksum',
    default_architecture: 'architecture flagged as the default for the provider when the version has it',
    snapshot: 'rclone path of the registry snapshot that supplies the description of a new document'
  }.freeze
  CHECKSUM_PATTERN = /\A[0-9a-fA-F]{64}\z/.freeze
  USAGE = "usage: vagrant_metadata.rb publish #{PUBLISH_OPTIONS.keys.map { |option| "--#{option.to_s.tr('_', '-')} <value>" }.join(' ')}".freeze

  def parse_publish_options(arguments)
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = USAGE
      PUBLISH_OPTIONS.each do |option, description|
        opts.on("--#{option.to_s.tr('_', '-')} VALUE", description) { |value| options[option] = value }
      end
    end
    rest = parser.parse(arguments)
    raise ArgumentError, "unexpected arguments: #{rest.join(' ')}" unless rest.empty?

    missing = PUBLISH_OPTIONS.keys.reject { |option| options.key?(option) && !options[option].empty? }
    raise ArgumentError, "missing options: #{missing.map { |option| "--#{option.to_s.tr('_', '-')}" }.join(', ')}" unless missing.empty?
    raise ArgumentError, "the checksum is not a SHA256 hex digest: #{options[:checksum]}" unless options[:checksum] =~ CHECKSUM_PATTERN

    options
  end

  def run(arguments, runner: Open3.method(:capture3), log: $stdout, error: $stderr)
    command, *command_arguments = arguments
    unless command == 'publish'
      error.puts USAGE
      return 1
    end

    options = parse_publish_options(command_arguments)
    key = "#{options[:author]}/#{options[:box]}"
    entry = Entry.new(options[:version], options[:provider], options[:architecture], options[:url], options[:checksum])
    description_source = -> { read_snapshot_description(rclone_cat(options[:snapshot], runner: runner), options[:box]) }
    result = publish(
      store: RcloneStore.new(options[:destination], runner: runner),
      key: key,
      entry: entry,
      name: key,
      default_architecture: options[:default_architecture],
      description_source: description_source,
      log: log
    )
    log.puts "#{key}: #{result}"
    0
  rescue StandardError => e
    error.puts e.message
    1
  end
end

exit VagrantMetadata.run(ARGV) if $PROGRAM_NAME == __FILE__
