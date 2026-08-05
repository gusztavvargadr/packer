# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'zlib'

require_relative 'collect'

# Exercises Azure log response decoding without network access.
class CollectTest < Minitest::Test
  FakeResponse = Struct.new(:body, :content_encoding) do
    def [](name)
      name.casecmp('content-encoding').zero? ? content_encoding : nil
    end
  end

  def test_decoded_response_body_decompresses_gzip
    compressed = StringIO.new
    Zlib::GzipWriter.wrap(compressed) { |writer| writer.write("benchmark log\n") }
    response = FakeResponse.new(compressed.string, 'gzip')

    assert_equal "benchmark log\n", decoded_response_body(response)
  end
end
