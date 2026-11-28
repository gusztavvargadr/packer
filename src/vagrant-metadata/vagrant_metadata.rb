require 'json'

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
end
