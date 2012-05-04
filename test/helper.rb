require 'minitest/spec'
require 'fivemat/minitest/autorun'

require 'tmpdir'
require 'fileutils'
require 'pathname'

require 'config'

class ConfigSpec < MiniTest::Spec

  register_spec_type(self) { |desc| true }

  def execute_pattern(pattern=subject)
    # Accumulate patterns
    accumulation = Config::Core::Accumulation.new
    pattern.accumulation = accumulation

    # Call the pattern under test.
    pattern.call

    # Now execute the result.
    executor = Config::Core::Executor.new(accumulation)
    executor.accumulate
    executor.validate!
    executor.resolve!
    executor.execute
  end

  def log
    Config.log
  end

  def log_string
    log_stream.string
  end

  let(:log_stream) { StringIO.new }

  before do
    Config.log_to log_stream
    Config.log_color false
  end

end

class FilesystemSpec < ConfigSpec

  register_spec_type(self) { |desc| desc =~ /filesystem/ }

  # Create a temporary directory. This directory will exist for the life of
  # the spec.
  #
  # id - Identifier of the tmpdir (default: the default identifier).
  #
  # Returns a Pathname.
  def tmpdir(id=:default)
    @tmpdirs[id] ||= Pathname.new(Dir.mktmpdir)
  end

  before do
    @tmpdirs = {}
  end

  after do
    @tmpdirs.values.each { |dir| FileUtils.rm_rf dir.to_s }
  end
end

