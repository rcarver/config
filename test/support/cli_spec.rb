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

  # A StringIO that responds true to `tty?`.
  class StringIOTTY < StringIO
    def tty?
      true
    end
  end

  #
  # The CLI execution environment.
  #

  # Set to a String to simulate STDIN.
  let(:tty) { nil }

  # The STDIN stream.
  let(:stdin) { tty ? StringIOTTY.new(tty) : StringIO.new }

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

  # Fake the Config world.
  let(:project)  { MiniTest::Mock.new }
  let(:data_dir) { MiniTest::Mock.new }

  # Fake the execution environment.
  let(:kernel)   { SimpleMock.new(FakeKernel.new(stdout, stderr)) }

  # Fake system calls.
  let(:system)   { MiniTest::Mock.new }
  let(:open3)    { FakeOpen3.new(system) }

  before do

    # Never execute against the filesystem.
    cli.noop!

    # Inject fake objects.
    cli.project = project
    cli.data_dir = data_dir
    cli.kernel = kernel
    cli.open3 = open3

    # Accumulate fake files that we use.
    @files = []
  end

  after do
    project.verify
    kernel.verify
    system.verify
    @files.each { |f| f.verify }
  end
end

