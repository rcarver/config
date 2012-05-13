require 'minitest/spec'
require 'simple_mock'
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

  # Change the current directory for the life of a block.
  #
  # Yields.
  #
  # Returns nothing.
  def within(dir, &block)
    Dir.chdir(dir, &block)
  end

  # Execute a shell command.
  #
  # command - String command to run.
  #
  # Returns the stdout + stderr.
  # Raises a RuntimeError if the exit status is not 0.
  def cmd(command)
    o, s = Open3.capture2e(command)
    raise o unless s.exitstatus == 0
    o
  end

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

