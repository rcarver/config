require 'minitest/spec'
require 'simple_mock'
require 'fivemat/minitest/autorun'

require 'fileutils'
require 'ostruct'
require 'pathname'
require 'tmpdir'

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

class CliSpec < MiniTest::Spec

  register_spec_type(self) { |desc| desc.to_s =~ /Config::CLI/ }

  class FakeKernel

    def initialize(stdout, stderr)
      @stdout = stdout
      @stderr = stderr
      @exitstatus = 0
    end

    attr_reader :exitstatus

    def abort(msg)
      stderr.puts(msg)
      exit(1)
    end

    def exit(status = 0)
      @exitstatus = status
      throw :exit, @exitstatus
    end
  end

  class FakeOpen3

    def initialize(system)
      @system = system
    end

    def capture3(command)
      stdout, stderr, exitstatus = @system.call(command)
      return stdout, stderr, OpenStruct.new(exitstatus: exitstatus)
    end
  end

  # The CLI execution environment.
  let(:stdin)  { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:argv) { "" }
  let(:env)  { Hash.new }

  # The subject for this test case.
  let(:cli) { subject.new("test-command", stdin, stdout, stderr) }

  # Mock a system call will occur.
  #
  # stdout  - String the stdout of the command.
  # stderr  - String the stderr of the command.
  # status  - Integer the exit code of the command.
  # command - String the command to run.
  #
  # Returns nothing.
  def expect_system_call(stdout, stderr, status, command)
    system.expect(:call, [stdout, stderr, status], [command])
  end

  # Expect that a Config::File will be writen.
  #
  # content - String the content to write.
  #
  # Returns a MiniTest::Mock.
  def expect_write_file(content)
    file = MiniTest::Mock.new
    @files << file
    file.expect(:write, nil, [content])
    file
  end

  # Fake the config world.
  let(:project)  { MiniTest::Mock.new }
  let(:data_dir) { MiniTest::Mock.new }

  # Fake the execution environment.
  let(:kernel)   { SimpleMock.new(FakeKernel.new(stdout, stderr)) }

  # Fake system calls.
  let(:open3)    { FakeOpen3.new(system) }
  let(:system)   { MiniTest::Mock.new }

  before do
    cli.project = project
    cli.data_dir = data_dir
    cli.kernel = kernel
    cli.open3 = open3
    @files = []
  end

  after do
    project.verify
    kernel.verify
    system.verify
    @files.each { |f| f.verify }
  end
end
