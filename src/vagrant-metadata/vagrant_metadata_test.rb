require 'digest'
require 'json'
require 'stringio'

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

    KEY = NAME

    class FakeStore
      attr_reader :writes, :reads

      def initialize(objects = {}, before_write: nil)
        @objects = {}
        @counter = 0
        @writes = []
        @reads = 0
        @before_write = before_write
        objects.each { |key, body| put(key, body) }
      end

      def put(key, body)
        @counter += 1
        @objects[key] = [body, "etag-#{@counter}"]
      end

      def body(key)
        @objects.fetch(key).first
      end

      def document(key)
        JSON.parse(body(key))
      end

      def read(key)
        @reads += 1
        current = @objects[key]
        current.nil? ? nil : current.dup
      end

      def write(key, body, etag)
        @writes << [key, body, etag]
        @before_write.call(self, key, @writes.length) unless @before_write.nil?
        current = @objects[key]
        accepted = etag.nil? ? current.nil? : !current.nil? && current[1] == etag
        put(key, body) if accepted
        accepted
      end
    end

    class Status
      def initialize(code)
        @code = code
      end

      def success?
        @code.zero?
      end

      def exitstatus
        @code
      end
    end

    class StubRunner
      attr_reader :calls

      def initialize(responses)
        @responses = responses
        @calls = []
      end

      def call(*arguments, **options)
        @calls << [arguments, options]
        response = @responses.shift
        raise "unexpected command: #{arguments.join(' ')}" if response.nil?

        stdout, stderr, code = response
        [stdout, stderr, Status.new(code)]
      end
    end

    REJECTED_STDERR = 'ERROR : x: Post request rcat error: operation error S3: PutObject, https response error StatusCode: 412, RequestID: , HostID: , api error PreconditionFailed: At least one of the pre-conditions you specified did not hold.'.freeze

    def publish_with(store, publish_entry = entry, **options)
      log = StringIO.new
      arguments = {
        store: store,
        key: KEY,
        entry: publish_entry,
        name: NAME,
        default_architecture: 'amd64',
        description_source: -> { 'D' },
        sleeper: ->(_seconds) {},
        log: log
      }.merge(options)
      [VagrantMetadata.publish(**arguments), log.string]
    end

    def existing_body(entries)
      VagrantMetadata.serialize(merge_all({ 'name' => NAME, 'description' => 'old', 'versions' => [] }, entries))
    end

    def stat_json(body)
      JSON.generate({ 'Path' => 'x', 'IsDir' => false, 'Hashes' => { 'md5' => Digest::MD5.hexdigest(body) } })
    end

    def test_publish_creates_missing_document
      store = FakeStore.new
      result, = publish_with(store)

      assert_equal(:created, result, 'publish result for a missing document')
      assert_equal('D', store.document(KEY)['description'], 'created description')
      assert_equal(1, store.writes.length, 'writes for a missing document')
      assert_equal(nil, store.writes[0][2], 'etag of the create write')
    end

    def test_publish_updates_existing_document
      store = FakeStore.new(KEY => existing_body([entry(provider: 'hyperv')]))
      etag = store.read(KEY)[1]
      calls = 0
      result, = publish_with(store, entry, description_source: -> { calls += 1 })

      assert_equal(:updated, result, 'publish result for an existing document')
      assert_equal(etag, store.writes[0][2], 'etag of the update write')
      assert_equal('old', store.document(KEY)['description'], 'existing description')
      assert_equal(0, calls, 'description source called for an existing document')
    end

    def test_publish_unchanged_skips_write
      store = FakeStore.new(KEY => existing_body([entry]))
      result, = publish_with(store)

      assert_equal(:unchanged, result, 'publish result for an identical entry')
      assert_equal(0, store.writes.length, 'writes for an identical entry')
    end

    def test_publish_retries_after_rejected_write
      other = lambda do |store, key, count|
        store.put(key, existing_body([entry(provider: 'hyperv')])) if count == 1
      end
      store = FakeStore.new(KEY => existing_body([]), before_write: other)
      sleeps = []
      result, = publish_with(store, entry, sleeper: ->(seconds) { sleeps << seconds })

      assert_equal(:updated, result, 'publish result after a rejected write')
      assert_equal(%w[hyperv libvirt], store.document(KEY)['versions'][0]['providers'].map { |item| item['name'] }, 'providers after a retry')
      assert_equal(1, sleeps.length, 'sleeps after one rejected write')
      assert(sleeps[0] >= 1.0 && sleeps[0] <= 4.0, "retry delay out of range: #{sleeps[0]}")
    end

    def test_publish_retries_create_after_rejected_write
      other = lambda do |store, key, count|
        store.put(key, existing_body([entry(provider: 'hyperv')])) if count == 1
      end
      store = FakeStore.new({}, before_write: other)
      result, = publish_with(store)

      assert_equal(:updated, result, 'publish result after a lost create race')
      assert_equal('old', store.document(KEY)['description'], 'description after a lost create race')
      assert_equal(%w[hyperv libvirt], store.document(KEY)['versions'][0]['providers'].map { |item| item['name'] }, 'providers after a lost create race')
    end

    def test_publish_gives_up_after_attempts
      other_body = existing_body([entry(provider: 'hyperv')])
      other = ->(store, key, _count) { store.put(key, other_body) }
      store = FakeStore.new(KEY => existing_body([]), before_write: other)

      assert_raises(RuntimeError, 'publish after every write was rejected') { publish_with(store, entry, attempts: 3) }
      assert_equal(3, store.writes.length, 'writes before giving up')
      assert_equal(other_body, store.body(KEY), 'document after giving up')
    end

    def test_publish_conflicting_entry_writes_nothing
      store = FakeStore.new(KEY => existing_body([entry]))

      assert_raises(ConflictingEntryError, 'publish of a conflicting entry') { publish_with(store, entry(checksum: 'b' * 64)) }
      assert_equal(0, store.writes.length, 'writes for a conflicting entry')
    end

    def test_snapshot_failure_writes_nothing
      store = FakeStore.new

      assert_raises(RuntimeError, 'publish with a failing snapshot') { publish_with(store, entry, description_source: -> { raise 'snapshot unavailable' }) }
      assert_equal(0, store.writes.length, 'writes with a failing snapshot')
    end

    def test_snapshot_description
      snapshot = '{"boxes":[{"name":"ubuntu-server","description":"D"},{"name":"e","description":""}]}'

      assert_equal('D', VagrantMetadata.read_snapshot_description(snapshot, 'ubuntu-server'), 'snapshot description')
      assert_equal(nil, VagrantMetadata.read_snapshot_description(snapshot, 'e'), 'empty snapshot description')
      assert_equal(nil, VagrantMetadata.read_snapshot_description(snapshot, 'missing'), 'missing snapshot box')
      assert_raises(JSON::ParserError, 'malformed snapshot') { VagrantMetadata.read_snapshot_description('', 'ubuntu-server') }
    end

    def test_publish_logs_recovery_values
      store = FakeStore.new
      _result, log = publish_with(store)
      lines = log.lines

      assert(lines[0].include?(entry.url) && lines[0].include?(entry.checksum), "first log line lacks the recovery values: #{lines[0]}")
      assert(log.include?('missing'), 'log lacks the missing document')
      assert(log.include?(store.body(KEY)), 'log lacks the document after the merge')
      assert(log.include?('accepted'), 'log lacks the write result')

      store = FakeStore.new(KEY => existing_body([entry(provider: 'hyperv')]))
      before = store.body(KEY)
      _result, log = publish_with(store)
      assert(log.include?(before), 'log lacks the document before the merge')
    end

    def test_rclone_cat_returns_output
      runner = StubRunner.new([['{"boxes":[]}', '', 0]])

      assert_equal('{"boxes":[]}', VagrantMetadata.rclone_cat('r2:packer/s.json', runner: runner), 'rclone cat output')
      assert_equal(%w[rclone cat r2:packer/s.json], runner.calls[0][0], 'rclone cat arguments')
    end

    def test_rclone_cat_failure_raises
      runner = StubRunner.new([['', 'boom', 1]])
      assert_raises(RuntimeError, 'failing rclone cat') { VagrantMetadata.rclone_cat('r2:packer/s.json', runner: runner) }

      runner = StubRunner.new([['', '', 0]])
      assert_raises(RuntimeError, 'empty rclone cat') { VagrantMetadata.rclone_cat('r2:packer/s.json', runner: runner) }
    end

    def test_rclone_read_missing_returns_nil
      runner = StubRunner.new([["null\n", '', 0]])
      store = VagrantMetadata::RcloneStore.new('r2:vagrant', runner: runner)

      assert_equal(nil, store.read(KEY), 'read of a missing object')
      assert_equal(['rclone', 'lsjson', '--stat', '--hash', '--files-only', "r2:vagrant/#{KEY}"], runner.calls[0][0], 'stat arguments')
    end

    def test_rclone_read_returns_body_and_etag
      body = existing_body([entry])
      runner = StubRunner.new([[stat_json(body), '', 0], [body, '', 0]])
      store = VagrantMetadata::RcloneStore.new('r2:vagrant', runner: runner)

      assert_equal([body, Digest::MD5.hexdigest(body)], store.read(KEY), 'read of a present object')
      assert_equal(['rclone', 'cat', "r2:vagrant/#{KEY}"], runner.calls[1][0], 'cat arguments')
    end

    def test_rclone_read_failure_raises
      runner = StubRunner.new([['', 'directory not found', 3]])
      store = VagrantMetadata::RcloneStore.new('r2:vagrant', runner: runner)

      assert_raises(RuntimeError, 'failing stat') { store.read(KEY) }
    end

    def test_rclone_read_mismatched_etag_rereads
      old_body = existing_body([])
      new_body = existing_body([entry])
      runner = StubRunner.new([[stat_json(old_body), '', 0], [new_body, '', 0], [stat_json(new_body), '', 0], [new_body, '', 0]])
      store = VagrantMetadata::RcloneStore.new('r2:vagrant', runner: runner)

      assert_equal([new_body, Digest::MD5.hexdigest(new_body)], store.read(KEY), 'read after the object changed between stat and cat')
      assert_equal(4, runner.calls.length, 'rclone calls for a changing object')
    end

    def test_rclone_read_keeps_changing_raises
      bodies = [existing_body([]), existing_body([entry]), existing_body([entry(provider: 'hyperv')])]
      responses = bodies.map { |body| [[stat_json(body), '', 0], [body.reverse, '', 0]] }.flatten(1)
      store = VagrantMetadata::RcloneStore.new('r2:vagrant', runner: StubRunner.new(responses))

      assert_raises(RuntimeError, 'read of an object that keeps changing') { store.read(KEY) }
    end

    def test_rclone_write_sends_conditions
      runner = StubRunner.new([['', '', 0], ['', '', 0]])
      store = VagrantMetadata::RcloneStore.new('r2:vagrant', runner: runner)

      assert_equal(true, store.write(KEY, 'body', nil), 'create write result')
      assert_equal(true, store.write(KEY, 'body', 'abc'), 'update write result')
      create_arguments, create_options = runner.calls[0]
      update_arguments, = runner.calls[1]
      common = ['rclone', 'rcat', "r2:vagrant/#{KEY}", '--header-upload', 'Content-Type: application/json']
      assert_equal(common + ['--header-upload', 'If-None-Match: *'], create_arguments.first(7), 'create arguments')
      assert_equal(common + ['--header-upload', 'If-Match: "abc"'], update_arguments.first(7), 'update arguments')
      %w[--streaming-upload-cutoff --retries --low-level-retries].each do |flag|
        assert(create_arguments.include?(flag), "write lacks #{flag}")
      end
      assert_equal('body', create_options[:stdin_data], 'write body')
    end

    def test_rclone_write_rejected_returns_false
      runner = StubRunner.new([['', REJECTED_STDERR, 1]])
      store = VagrantMetadata::RcloneStore.new('r2:vagrant', runner: runner)

      assert_equal(false, store.write(KEY, 'body', 'abc'), 'rejected write result')
    end

    def test_rclone_write_other_failure_raises
      runner = StubRunner.new([['', 'AccessDenied: Access Denied', 1]])
      store = VagrantMetadata::RcloneStore.new('r2:vagrant', runner: runner)

      store.write(KEY, 'body', 'abc')
      raise 'a failed write did not raise'
    rescue RuntimeError => error
      raise if error.message == 'a failed write did not raise'

      assert(error.message.include?('AccessDenied: Access Denied'), "write failure lacks rclone's stderr: #{error.message}")
    end

    def cli_arguments(overrides = {})
      options = {
        '--destination' => 'r2:vagrant',
        '--author' => 'gusztavvargadr',
        '--box' => 'ubuntu-server-2404-lts',
        '--version' => '2610.0.0',
        '--provider' => 'libvirt',
        '--architecture' => 'amd64',
        '--url' => entry.url,
        '--checksum' => entry.checksum,
        '--default-architecture' => 'amd64',
        '--snapshot' => 'r2:packer/s.json'
      }.merge(overrides)
      ['publish'] + options.reject { |_name, value| value.nil? }.to_a.flatten
    end

    def test_cli_publishes_new_document
      snapshot = '{"boxes":[{"name":"ubuntu-server-2404-lts","description":"Ubuntu"}]}'
      runner = StubRunner.new([["null\n", '', 0], [snapshot, '', 0], ['', '', 0]])
      log = StringIO.new
      code = VagrantMetadata.run(cli_arguments, runner: runner, log: log, error: StringIO.new)

      assert_equal(0, code, 'CLI exit code')
      arguments, options = runner.calls[2]
      assert_equal("r2:vagrant/#{NAME}", arguments[2], 'CLI write path')
      document = JSON.parse(options[:stdin_data])
      assert_equal(NAME, document['name'], 'CLI document name')
      assert_equal('Ubuntu', document['description'], 'CLI document description')
      assert_equal(entry.url, document['versions'][0]['providers'][0]['url'], 'CLI entry URL')
      assert(log.string.include?('created'), 'CLI log lacks the result')
    end

    def test_cli_rejects_missing_option
      error = StringIO.new
      code = VagrantMetadata.run(cli_arguments('--snapshot' => nil), runner: StubRunner.new([]), log: StringIO.new, error: error)

      assert_equal(1, code, 'CLI exit code without --snapshot')
      assert(error.string.include?('--snapshot'), "CLI error does not name the missing option: #{error.string}")
    end

    def test_cli_rejects_malformed_checksum
      error = StringIO.new
      code = VagrantMetadata.run(cli_arguments('--checksum' => 'abc'), runner: StubRunner.new([]), log: StringIO.new, error: error)

      assert_equal(1, code, 'CLI exit code with a malformed checksum')
      assert(error.string.include?('checksum'), "CLI error does not name the checksum: #{error.string}")
    end

    def test_cli_reports_failure
      error = StringIO.new
      code = VagrantMetadata.run(cli_arguments, runner: StubRunner.new([['', 'AccessDenied', 1]]), log: StringIO.new, error: error)

      assert_equal(1, code, 'CLI exit code after an rclone failure')
      assert(error.string.include?('AccessDenied'), "CLI error lacks rclone's stderr: #{error.string}")
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
