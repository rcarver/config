class CliSpec < MiniTest::Spec

  register_spec_type(self) do |desc|
    desc.is_a?(Class) && desc.superclass == Config::CLI::Base
  end

  # A replacement for Kernel that doesn't exit the process.
  class FakeKernel

    def initialize(stdout, stderr)
      @stdout = stdout
      @stderr = stderr
      @exitstatus = 0
    end

    attr_reader :exitstatus

    def abort(msg)
      @stderr.puts msg
      exit(1)
    end

    def exit(status = 0)
      @exitstatus = status
      throw :exit, @exitstatus
    end
  end

  # A replacement for Open3 that doesn't talk to the OS.
  class FakeOpen3

    def initialize(system)
      @system = system
    end

    def capture3(command)
      stdout, stderr, exitstatus = @system.call(command)
      return stdout, stderr, OpenStruct.new(exitstatus: exitstatus)
    end
  end

  # Simulate STDIN where no input stream is present.
  class FakeTTY
    def tty?
      true
    end
  end

  #
  # The CLI execution environment.
  #

  # Set to a String to simulate STDIN.
  let(:input_stream) { nil }

  # The STDIN stream.
  let(:stdin) { input_stream ? StringIO.new(input_stream) : FakeTTY.new }

  # The STDOUT stream.
  let(:stdout) { StringIO.new }

  # The STDERR stream.
  let(:stderr) { StringIO.new }

  # The ARGV Array.
  let(:argv) { [] }

  # The ENV Hash.
  let(:env) { Hash.new }


  # The subject for this test case. Use `cli` instead of `subject`.
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

  # Expect that the program will fail, and print usage information.
  def expect_fail_with_usage(&block)
    proc(&block).must_throw :exit
    stderr.string.chomp.must_equal cli.usage
  end

  # Expect for another ClI command to be called.
  #
  # name - String name of the command.
  #
  # Returns a MiniTest::Mock.
  def expect_subcommand(name)
    command = MiniTest::Mock.new
    command.expect(:execute, nil)
    @subcommands << command
    subcommand_builder.expect(:call, command, [name])
    command
  end

  # Fake subcommand creator.
  let(:subcommand_builder) { MiniTest::Mock.new }

  # Fake the Config world.
  let(:project)      { MiniTest::Mock.new }
  let(:project_data) { MiniTest::Mock.new }
  let(:database)     { MiniTest::Mock.new }

  # Fake the execution environment.
  let(:kernel)   { SimpleMock.new(FakeKernel.new(stdout, stderr)) }

  # Fake system calls.
  let(:system)   { MiniTest::Mock.new }
  let(:open3)    { FakeOpen3.new(system) }

  before do

    # Never execute against the filesystem.
    cli.noop!

    # Inject fake objects.
    cli.subcommand_builder = subcommand_builder
    cli.project = project
    cli.project_data = project_data
    cli.database = database
    cli.kernel = kernel
    cli.open3 = open3

    # Accumulate fake files that we use.
    @files = []

    # Accumulate fake subcommands.
    @subcommands = []
  end

  after do
    subcommand_builder.verify
    project.verify
    project_data.verify
    database.verify
    kernel.verify
    system.verify
    @files.each { |f| f.verify }
    @subcommands.each { |c| c.verify }
  end
end

