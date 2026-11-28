require 'json'

require_relative 'vagrant_metadata'

module VagrantMetadata
  module VagrantMetadataTest
    module_function

    NAME = 'gusztavvargadr/ubuntu-server-2404-lts'.freeze

    def assert(condition, message)
      raise message unless condition
    end

    def assert_equal(expected, actual, message)
      assert(expected == actual, "#{message}: expected #{expected.inspect}, got #{actual.inspect}")
    end

    def assert_raises(error_class, message)
      yield
    rescue error_class
      nil
    else
      raise "#{message}: #{error_class} was not raised"
    end

    def deep_copy(value)
      Marshal.load(Marshal.dump(value))
    end

    def entry(version: '2610.0.0', provider: 'libvirt', architecture: 'amd64', url: nil, checksum: 'a' * 64)
      url ||= "https://images.packer.gusztavvargadr.me/ubuntu-server-2404-lts/#{version}/#{provider}/#{architecture}/vagrant.box"
      Entry.new(version, provider, architecture, url, checksum)
    end

    def merge_all(document, entries, default_architecture: 'amd64')
      entries.reduce(document) do |current, item|
        VagrantMetadata.merge(current, item, name: NAME, default_architecture: default_architecture).first
      end
    end

    def find_version(document, version)
      document['versions'].find { |item| item['version'] == version }
    end

    def find_provider(document, version, name, architecture)
      find_version(document, version)['providers'].find { |item| item['name'] == name && item['architecture'] == architecture }
    end

    def test_creates_document
      e = entry
      document, changed = VagrantMetadata.merge(nil, e, name: NAME, default_architecture: 'amd64', description: 'D')

      assert_equal(true, changed, 'a new document was not reported as changed')
      assert_equal(%w[name description versions], document.keys, 'new document keys')
      assert_equal(NAME, document['name'], 'new document name')
      assert_equal('D', document['description'], 'new document description')
      expected = {
        'version' => '2610.0.0',
        'status' => 'active',
        'providers' => [
          {
            'name' => 'libvirt',
            'url' => e.url,
            'checksum' => e.checksum,
            'checksum_type' => 'SHA256',
            'architecture' => 'amd64',
            'default_architecture' => true
          }
        ]
      }
      assert_equal([expected], document['versions'], 'new document versions')
      assert_equal(%w[name url checksum checksum_type architecture default_architecture], document['versions'][0]['providers'][0].keys, 'new entry keys')
    end

    def test_creates_document_without_description
      [nil, ''].each do |description|
        document, _changed = VagrantMetadata.merge(nil, entry, name: NAME, default_architecture: 'amd64', description: description)
        assert(!document.key?('description'), "a document created with description #{description.inspect} has a description key")
        assert_equal(%w[name versions], document.keys, 'document keys without description')
      end
    end

    def test_keeps_name_and_description
      input = { 'name' => 'x', 'description' => 'old', 'versions' => [] }
      document, changed = VagrantMetadata.merge(input, entry, name: NAME, default_architecture: 'amd64', description: 'new')

      assert_equal(true, changed, 'a merged entry was not reported as changed')
      assert_equal('x', document['name'], 'existing name')
      assert_equal('old', document['description'], 'existing description')
    end

    def test_adds_entry_to_existing_version
      document = merge_all(nil, [entry, entry(provider: 'hyperv')])

      assert_equal(['2610.0.0'], document['versions'].map { |item| item['version'] }, 'versions after adding a provider')
      assert_equal(%w[hyperv libvirt], document['versions'][0]['providers'].map { |item| item['name'] }, 'provider order')
    end

    def test_identical_entry_is_unchanged
      first, = VagrantMetadata.merge(nil, entry, name: NAME, default_architecture: 'amd64')
      second, changed = VagrantMetadata.merge(first, entry(checksum: 'A' * 64), name: NAME, default_architecture: 'amd64')

      assert_equal(false, changed, 'an identical entry was reported as changed')
      assert_equal(first, second, 'document after an identical entry')
    end

    def test_conflicting_entry_raises
      document = merge_all(nil, [entry])

      assert_raises(ConflictingEntryError, 'a different checksum') do
        VagrantMetadata.merge(document, entry(checksum: 'b' * 64), name: NAME, default_architecture: 'amd64')
      end
      assert_raises(ConflictingEntryError, 'a different URL') do
        VagrantMetadata.merge(document, entry(url: 'https://example.com/vagrant.box'), name: NAME, default_architecture: 'amd64')
      end
    end

    def test_default_architecture_prefers_configured
      document = merge_all(nil, [entry(provider: 'vmware_desktop', architecture: 'arm64'), entry(provider: 'vmware_desktop', architecture: 'amd64')])

      assert_equal(true, find_provider(document, '2610.0.0', 'vmware_desktop', 'amd64')['default_architecture'], 'configured default architecture')
      assert_equal(false, find_provider(document, '2610.0.0', 'vmware_desktop', 'arm64')['default_architecture'], 'other architecture')
      assert_equal(%w[amd64 arm64], document['versions'][0]['providers'].map { |item| item['architecture'] }, 'architecture order')
    end

    def test_default_architecture_falls_back_to_only_architecture
      document = merge_all(nil, [entry(provider: 'vmware_desktop', architecture: 'arm64')])

      assert_equal(true, find_provider(document, '2610.0.0', 'vmware_desktop', 'arm64')['default_architecture'], 'only architecture')
    end

    def test_default_architecture_falls_back_to_first_architecture
      document = merge_all(nil, [entry(provider: 'vmware_desktop', architecture: 'arm64'), entry(provider: 'vmware_desktop', architecture: 'arm32')], default_architecture: 'amd64')

      assert_equal(true, find_provider(document, '2610.0.0', 'vmware_desktop', 'arm32')['default_architecture'], 'alphabetically first architecture')
      assert_equal(false, find_provider(document, '2610.0.0', 'vmware_desktop', 'arm64')['default_architecture'], 'later architecture')
    end

    def test_default_architecture_is_per_provider
      document = merge_all(nil, [entry(provider: 'vmware_desktop', architecture: 'arm64'), entry(provider: 'libvirt', architecture: 'amd64')])

      assert_equal(true, find_provider(document, '2610.0.0', 'vmware_desktop', 'arm64')['default_architecture'], 'vmware_desktop default')
      assert_equal(true, find_provider(document, '2610.0.0', 'libvirt', 'amd64')['default_architecture'], 'libvirt default')
    end

    def test_versions_sort_numerically_newest_first
      document = merge_all(nil, [entry(version: '2610.9.0'), entry(version: '2610.10.0'), entry(version: '2607.1.0')])

      assert_equal(['2610.10.0', '2610.9.0', '2607.1.0'], document['versions'].map { |item| item['version'] }, 'version order')
    end

    def test_other_versions_untouched
      other = {
        'version' => '2607.1.0',
        'status' => 'active',
        'providers' => [
          { 'name' => 'vmware_desktop', 'url' => 'u', 'checksum' => 'c', 'checksum_type' => 'SHA256', 'architecture' => 'arm64', 'default_architecture' => true, 'foo' => 1 },
          { 'name' => 'libvirt', 'url' => 'u2', 'checksum' => 'c2', 'checksum_type' => 'SHA256', 'architecture' => 'amd64', 'default_architecture' => false }
        ]
      }
      input = { 'name' => NAME, 'versions' => [deep_copy(other)] }
      document, = VagrantMetadata.merge(input, entry, name: NAME, default_architecture: 'amd64')

      assert_equal(other, find_version(document, '2607.1.0'), 'other version')
    end

    def test_merge_does_not_mutate_input
      input = merge_all(nil, [entry])
      before = deep_copy(input)
      VagrantMetadata.merge(input, entry(provider: 'hyperv'), name: NAME, default_architecture: 'amd64')

      assert_equal(before, input, 'input document after merge')
    end

    def test_serialize
      document, = VagrantMetadata.merge(nil, entry, name: NAME, default_architecture: 'amd64')
      body = VagrantMetadata.serialize(document)

      assert_equal("#{JSON.pretty_generate(document)}\n", body, 'serialized document')
      assert_equal(document, JSON.parse(body), 'parsed serialized document')
    end

    def run
      tests = methods.map(&:to_s).select { |name| name.start_with?('test_') }.sort
      tests.each do |name|
        public_send(name)
        puts "#{name}: passed"
      end
      puts "#{tests.length} tests passed"
    end
  end
end

VagrantMetadata::VagrantMetadataTest.run
