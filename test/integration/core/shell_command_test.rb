require 'helper'

describe Config::Core::ShellCommand do

  subject { Config::Core::ShellCommand.new }

  let(:stdouts) { [] }
  let(:stderrs) { [] }

  before do
    subject.on_stdout = -> line { stdouts << line }
    subject.on_stderr = -> line { stderrs << line }
  end

  it "executes a simple command, capturing STDOUT and STDERR output" do
    subject.command = "ruby"
    subject.args = "-r open3"
    subject.stdin_data = <<-STR.dent
      STDOUT.puts Open3
      STDERR.puts Open3.class
    STR

    subject.to_s.must_equal "ruby -r open3"

    subject.execute
    subject.exitstatus.must_equal 0
    subject.must_be :success?

    stdouts.must_equal ["Open3\n"]
    stderrs.must_equal ["Module\n"]
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
    subject.exitstatus.must_equal 0
    subject.must_be :success?

    stdouts.must_equal [
      "#\r",
      "##\r",
      "###\r",
      "done\n"
    ]
  end
end
