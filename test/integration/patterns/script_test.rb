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
    subject.prepare
    subject.public_send(run_mode)
  end

  before do
    subject.name = "test it out"
  end

  describe "#create" do

    before do
      subject.code = <<-STR
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

  describe "#create environment" do

    before do
      subject.code = <<-STR
        sh -c "export"
      STR
    end

    it "doesn't include bundler configuration" do
      execute :create
      log_string.wont_include "BUNDLE_BIN_PATH"
      log_string.wont_include "BUNDLE_GEMFILE"
      log_string.wont_include "GEM_HOME"
      log_string.wont_include "GEM_PATH"
    end
  end

  describe "#create logging" do

    it "logs stdout and stderr" do
      subject.code = <<-STR
        echo 'one to out' >&1
        echo 'one to err' >&2
        echo 'two to out' >&1
        echo 'two to err' >&2
      STR
      execute :create
      log_string.must_equal <<-STR
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
      subject.code = <<-STR
        echo 'one to out' >&1
        echo 'one to err' >&2
        exit 1
        echo 'two to out' >&1
        echo 'two to err' >&2
      STR
      proc { execute :create }.must_raise Config::Error
      log_string.must_equal <<-STR
  STATUS 1
  STDOUT
    one to out
  STDERR
    one to err
      STR
    end

    it "excludes the header if nothing is written" do
      subject.code = <<-STR
        echo hello > /dev/null
        exit 0
      STR
      execute :create
      log_string.must_equal <<-STR
  STATUS 0
      STR
    end
  end

  describe "#destroy" do

    before do
      subject.reverse = <<-STR
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
  end

  describe "#destroy when no reverse is given" do

    it "logs" do
      execute :destroy
      log_string.must_equal <<-STR
No reverse code was given
      STR
    end
  end
end


