require 'helper'
require 'ostruct'

describe Config::Patterns::Script do

  subject { Config::Patterns::Script.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:name]
  end

  specify "validity" do
    subject.name = "say ok"
    subject.code = "echo ok"
    subject.code_exec = "sh"
    subject.attribute_errors.must_be_empty
  end

  specify "#to_s" do
    subject.name = "say ok"
    subject.to_s.must_equal %(Script "say ok")
  end
end

describe "filesystem", Config::Patterns::Script do

  subject { Config::Patterns::Script.new }

  let(:path) { tmpdir + "test.txt" }

  def execute(run_mode)
    subject.run_mode = run_mode
    subject.prepare
    subject.public_send(run_mode)
  end

  before do
    subject.name = "test it out"
    subject.code_exec = "sh"
  end

  describe "#create" do

    before do
      subject.code = <<-STR.dent
        if [ ! -f #{path} ]; then
          echo hello > #{path}
        else
          exit 1
        fi
      STR
    end

    it "runs the script" do
      execute :create
      path.must_be :exist?
      path.read.must_equal "hello\n"
    end

    it "fails if the script returns non-zero status" do
      path.open("w") { |f| f.print "here" }
      proc { execute :create }.must_raise Config::Error
    end

    describe "the shell command" do

      let(:shell_command) { subject.send(:code_shell_command) }

      before do
        subject.code_exec = "bash"
        subject.code_args = "-e"
        subject.code_env = { "FOO" => "bar" }
      end

      it "uses code_exec, code_args and code_env" do
        shell_command.command.must_equal "bash"
        shell_command.args.must_equal "-e"
        shell_command.env.must_equal "FOO" => "bar"
      end
    end
  end

  describe "#create with not_if" do

    before do
      subject.code = <<-STR.dent
        echo hello > #{path}
      STR
    end

    it "runs the script when not_if is false" do
      subject.not_if = '[ 1 -eq 0 ]'
      execute :create
      path.must_be :exist?
    end

    it "doesn't run the script not_if is true" do
      subject.not_if = '[ 1 -eq 1 ]'
      execute :create
      path.wont_be :exist?
    end

    describe "the shell command" do

      let(:shell_command) { subject.send(:not_if_shell_command) }

      before do
        subject.code_exec = "bash"
        subject.code_args = "-e"
        subject.code_env = { "FOO" => "bar" }
      end

      it "uses code_exec, code_args and code_env by default" do
        shell_command.command.must_equal "bash"
        shell_command.args.must_equal "-e"
        shell_command.env.must_equal "FOO" => "bar"
      end

      it "can use its own command, args, and env" do
        subject.not_if_exec = "ruby"
        subject.not_if_args = "-I lib"
        subject.not_if_env = { "BAR" => "baz" }
        shell_command.command.must_equal "ruby"
        shell_command.args.must_equal "-I lib"
        shell_command.env.must_equal "BAR" => "baz"
      end

      it "uses no args if a not_if command is given but no args or env" do
        subject.not_if_exec = "ruby"
        shell_command.command.must_equal "ruby"
        shell_command.args.must_equal nil
        shell_command.env.must_equal nil
      end

      it "uses not_if args or env if given" do
        subject.not_if_args = "-e -u"
        subject.not_if_env = { "BAR" => "baz" }
        shell_command.command.must_equal "bash"
        shell_command.args.must_equal "-e -u"
        shell_command.env.must_equal "BAR" => "baz"
      end
    end
  end

  describe "#destroy" do

    before do
      subject.reverse = <<-STR.dent
        if [ -f #{path} ]; then
          rm #{path}
        else
          exit 1
        fi
      STR
    end

    it "runs the script" do
      path.open("w") { |f| f.print "here" }
      execute :destroy
      path.wont_be :exist?
    end

    it "fails if the script returns non-zero status" do
      proc { execute :destroy }.must_raise Config::Error
    end

    describe "the shell command" do

      let(:shell_command) { subject.send(:reverse_shell_command) }

      before do
        subject.code_exec = "bash"
        subject.code_args = "-e"
        subject.code_env = { "FOO" => "bar" }
      end

      it "uses code_exec and code_args by default" do
        shell_command.command.must_equal "bash"
        shell_command.args.must_equal "-e"
        shell_command.env.must_equal "FOO" => "bar"
      end

      it "can use its own command and args" do
        subject.reverse_exec = "ruby"
        subject.reverse_args = "-I lib"
        subject.reverse_env = { "BAR" => "baz" }
        shell_command.command.must_equal "ruby"
        shell_command.args.must_equal "-I lib"
        shell_command.env.must_equal "BAR" => "baz"
      end

      it "uses no args if a reverse command is given but no args" do
        subject.reverse_exec = "ruby"
        shell_command.command.must_equal "ruby"
        shell_command.args.must_equal nil
        shell_command.env.must_equal nil
      end

      it "uses reverse args if given" do
        subject.reverse_args = "-e -u"
        subject.reverse_env = { "BAR" => "baz" }
        shell_command.command.must_equal "bash"
        shell_command.args.must_equal "-e -u"
        shell_command.env.must_equal "BAR" => "baz"
      end
    end
  end

  describe "not_if logging" do

    before do
      subject.code = "echo 123"
    end

    specify "when false" do
      subject.not_if = '[ 1 -eq 0 ]'
      execute :create
      log_string.must_equal <<-STR.dent
        not_if sh
        [ 1 -eq 0 ]
        >>> sh
        echo 123
        <<<
        RUNNING (not_if exited with status 1)
        [o] 123
        [?] 0
      STR
    end

    specify "when true" do
      subject.not_if = '[ 1 -eq 1 ]'
      execute :create
      log_string.must_equal <<-STR.dent
        not_if sh
        [ 1 -eq 1 ]
        >>> sh
        echo 123
        <<<
        SKIPPED (not_if exited with zero status)
      STR
    end

    specify "when it has output" do
      subject.not_if = 'echo ok; test 0 -eq 1'
      execute :create
      log_string.must_equal <<-STR.dent
        not_if sh
        echo ok; test 0 -eq 1
        >>> sh
        echo 123
        <<<
        [o] ok
        RUNNING (not_if exited with status 1)
        [o] 123
        [?] 0
      STR
    end
  end

  describe "#destroy logging given" do

    it "logs if no reverse code is given" do
      execute :destroy
      log_string.must_equal <<-STR.dent
        No reverse code was given
      STR
    end
  end

  describe "specifics of logging" do

    it "logs stdout and stderr" do
      subject.code = <<-STR.dent
        echo 'one to out' >&1
        echo 'two to out' >&1
        echo 'one to err' >&2
        echo 'two to err' >&2
      STR
      execute :create
      # The output is non-deterministic due to the use of Thread to
      # capture both stout and stderr at the same time.
      output = log_string.split("\n")[5..-1].sort
      output.must_equal <<-STR.dent.split("\n").sort
        <<<
        [o] one to out
        [o] two to out
        [e] one to err
        [e] two to err
        [?] 0
      STR
    end

    it "shows the command and options that are used to run the code" do
      subject.code_exec = "ruby"
      subject.code_args = ["-r", "open3"]
      subject.code = <<-STR.dent
        puts Open3.class
      STR
      execute :create
      log_string.must_equal <<-STR.dent
        >>> ruby -r open3
        puts Open3.class
        <<<
        [o] Module
        [?] 0
      STR
    end

    it "logs control characters" do
      # NOTE: this is not complete but \b, \c and \n are weird.
      subject.code_exec = "bash"
      subject.code = <<-STR.dent
        test -n '\a'
        test -n '\f'
        test -n '\r'
        test -n '\t'
        test -n '\v'
      STR
      execute :create
      log_string.must_equal <<-STR.dent
        >>> bash
        test -n '\\a'
        test -n '\\f'
        test -n '\\r'
        test -n '\\t'
        test -n '\\v'
        <<<
        [?] 0
      STR
    end

    it "handles \r line continuations" do
      subject.code_exec = "bash"
      subject.code = <<-STR.dent
        echo -ne '#\r'
        echo -ne '##\r'
        echo -ne '###\r'
        echo done
      STR
      execute :create
      log_string.must_equal <<-STR.dent
        >>> bash
        echo -ne '#\\r'
        echo -ne '##\\r'
        echo -ne '###\\r'
        echo done
        <<<
        [o] #\r[o] ##\r[o] ###\r[o] done
        [?] 0
      STR
    end
  end
end
