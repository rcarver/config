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
    subject.attribute_errors.must_be_empty
  end

  specify "#to_s" do
    subject.name = "say ok"
    subject.to_s.must_equal %([Script "say ok"])
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
      log_string.must_equal <<-STR.dent(2)
          not_if
          [ 1 -eq 0 ]
          >>>
          echo hello > #{path}
          <<<
        RUNNING because not_if exited with status 1
        STATUS 0
      STR
    end

    it "doesn't run the script only_if is true" do
      subject.not_if = '[ 1 -eq 1 ]'
      execute :create
      path.wont_be :exist?
      log_string.must_equal <<-STR.dent(2)
          not_if
          [ 1 -eq 1 ]
          >>>
          echo hello > #{path}
          <<<
        SKIPPED because not_if exited with zero status
      STR
    end
  end

  describe "#create logging" do

    it "logs stdout and stderr" do
      subject.code = <<-STR.dent
        echo 'one to out' >&1
        echo 'one to err' >&2
        echo 'two to out' >&1
        echo 'two to err' >&2
      STR
      execute :create
      log_string.must_equal <<-STR.dent(2)
          >>>
          echo 'one to out' >&1
          echo 'one to err' >&2
          echo 'two to out' >&1
          echo 'two to err' >&2
          <<<
        STATUS 0
        STDOUT
          one to out
          two to out
        STDERR
          one to err
          two to err
      STR
    end

    it "logs even if the command fails" do
      subject.code = <<-STR.dent
        echo 'one to out' >&1
        echo 'one to err' >&2
        exit 1
        echo 'two to out' >&1
        echo 'two to err' >&2
      STR
      proc { execute :create }.must_raise Config::Error
      log_string.must_equal <<-STR.dent(2)
          >>>
          echo 'one to out' >&1
          echo 'one to err' >&2
          exit 1
          echo 'two to out' >&1
          echo 'two to err' >&2
          <<<
        STATUS 1
        STDOUT
          one to out
        STDERR
          one to err
      STR
    end

    it "excludes the header if nothing is written" do
      subject.code = <<-STR.dent
        echo hello > /dev/null
        exit 0
      STR
      execute :create
      log_string.must_equal <<-STR.dent(2)
          >>>
          echo hello > /dev/null
          exit 0
          <<<
        STATUS 0
      STR
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
      log_string.must_equal <<-STR.dent(2)
          >>>
          if [ -f #{path} ]; then
            rm #{path}
          else
            exit 1
          fi
          <<<
        STATUS 0
      STR
    end

    it "fails if the script returns non-zero status" do
      proc { execute :destroy }.must_raise Config::Error
    end
  end

  describe "#destroy when no reverse is given" do

    it "logs" do
      execute :destroy
      log_string.must_equal <<-STR.dent(4)
        No reverse code was given
      STR
    end
  end
end


