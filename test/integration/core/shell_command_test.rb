require 'helper'

describe Config::Core::ShellCommand do

  subject { Config::Core::ShellCommand.new }

  let(:stdouts) { [] }
  let(:stderrs) { [] }

  before do
    subject.on_stdout = -> line { stdouts << line }
    subject.on_stderr = -> line { stderrs << line }
  end

  it "accepts string args" do
    subject.command = "echo"
    subject.args = "one two three"

    subject.execute

    stderrs.must_equal []
    stdouts.must_equal ["one two three\n"]

    subject.to_s.must_equal "echo one two three"
  end

  it "accepts array args" do
    subject.command = "echo"
    subject.args = ["one", "two", "three"]

    subject.execute

    stderrs.must_equal []
    stdouts.must_equal ["one two three\n"]

    subject.to_s.must_equal "echo one two three"
  end

  it "executes a simple command, capturing STDOUT and STDERR output" do
    subject.command = "ruby"
    subject.args = "-r open3"
    subject.env = { "HELLO" => "hello" }
    subject.stdin_data = <<-STR.dent
      STDOUT.puts Open3
      STDERR.puts Open3.class
      STDOUT.puts ENV['HELLO']
    STR

    subject.execute

    stderrs.must_equal ["Module\n"]
    stdouts.must_equal ["Open3\n", "hello\n"]

    subject.exitstatus.must_equal 0
    subject.must_be :success?

    subject.to_s.must_equal "HELLO=hello ruby -r open3"
  end

  it "captures lines ending in \\r" do
    subject.command = "bash"
    subject.stdin_data = <<-STR.dent
      echo -ne '#\r'
      echo -ne '##\r'
      echo -ne '###\r'
      echo done
    STR

    subject.execute

    stderrs.must_equal []
    stdouts.must_equal [
      "#\r",
      "##\r",
      "###\r",
      "done\n"
    ]

    subject.exitstatus.must_equal 0
    subject.must_be :success?

    subject.to_s.must_equal "bash"
  end
end
