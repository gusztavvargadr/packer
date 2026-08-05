# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Style/Documentation

require 'digest'
require 'fileutils'
require 'json'
require 'minitest/autorun'
require 'open3'
require 'tmpdir'

class BenchmarkTest < Minitest::Test
  BENCHMARK = File.expand_path('benchmark.rb', __dir__)

  def test_verify_checksum_resolves_a_unique_nested_artifact
    Dir.mktmpdir do |directory|
      image = File.join(directory, 'image')
      FileUtils.mkdir_p(image)
      artifact = File.join(image, 'ubuntu-server.img')
      File.write(artifact, 'native-image')
      File.write(File.join(directory, 'checksum.sha256'), "#{Digest::SHA256.file(artifact).hexdigest}\tubuntu-server.img\n")

      stdout, stderr, status = Open3.capture3('ruby', BENCHMARK, 'verify-checksum', '--artifact-path', directory)

      assert status.success?, stderr
      result = JSON.parse(stdout)
      assert_equal 'image/ubuntu-server.img', result.fetch('entries').first.fetch('path')
      assert result.fetch('exact')
    end
  end

  def test_verify_checksum_rejects_an_ambiguous_nested_artifact
    Dir.mktmpdir do |directory|
      %w[first second].each do |subdirectory|
        path = File.join(directory, subdirectory)
        FileUtils.mkdir_p(path)
        File.write(File.join(path, 'ubuntu-server.img'), subdirectory)
      end
      checksum = Digest::SHA256.hexdigest('first')
      File.write(File.join(directory, 'checksum.sha256'), "#{checksum}\tubuntu-server.img\n")

      _stdout, stderr, status = Open3.capture3('ruby', BENCHMARK, 'verify-checksum', '--artifact-path', directory)

      refute status.success?
      assert_includes stderr, 'checksum target is ambiguous: ubuntu-server.img matched 2 files'
    end
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Style/Documentation
