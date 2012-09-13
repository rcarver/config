require 'helper'

describe Config::Patterns::Directory do

  subject { Config::Patterns::Directory.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:path]
  end

  specify "validity" do
    subject.path = "/tmp"
    subject.error_messages.must_be_empty
  end

  specify "#to_s" do
    subject.path = "/tmp//foo/"
    subject.to_s.must_equal "Directory /tmp/foo"
  end

  describe "#call" do

    before do
      subject.path = "/tmp/dir"
    end

    def call_pattern
      subject.accumulation = Config::Core::Accumulation.new
      subject.validate
      subject.prepare
      subject.call
      subject.accumulation.to_a
    end

    it "does nothing" do
      patterns = call_pattern
      patterns.size.must_equal 0
    end

    it "sets the directory owner" do
      subject.owner = "root"

      patterns = call_pattern
      patterns.size.must_equal 1

      chmod = patterns.find { |p| p.is_a? Config::Patterns::Chown }
      chmod.path.must_equal "/tmp/dir"
      chmod.owner.must_equal "root"
    end

    it "sets the directory group" do
      subject.group = "admin"

      patterns = call_pattern
      patterns.size.must_equal 1

      chmod = patterns.find { |p| p.is_a? Config::Patterns::Chown }
      chmod.path.must_equal "/tmp/dir"
      chmod.group.must_equal "admin"
    end

    it "sets the directory mode" do
      subject.mode = 0755

      patterns = call_pattern
      patterns.size.must_equal 1

      chmod = patterns.find { |p| p.is_a? Config::Patterns::Chmod }
      chmod.path.must_equal "/tmp/dir"
      chmod.mode.must_equal 0755
    end
  end
end

describe "filesystem", Config::Patterns::Directory do

  subject { Config::Patterns::Directory.new }

  let(:path) { tmpdir + "test" }

  before do
    subject.path = path.to_s
  end

  describe "#create" do

    it "creates a directory" do
      path.wont_be :exist?
      subject.create
      path.must_be :exist?
      subject.changes.must_include "created"
    end

    it "does nothing if the directory exists" do
      path.mkdir
      subject.create
      path.must_be :exist?
      subject.wont_be :changed?
    end

    it "does not create recursively" do
      # Rationale: The rules of ownership are unclear when you `mkdir
      # -p`. `man mkdir` explains what happens but we would prefer more
      # explicit code.  More importantly, it's unclear which part of the
      # path is expected to exist previously and therefore which parts
      # you are creating.
      subject.path = path + "foo"
      proc { subject.create }.must_raise Errno::ENOENT
    end
  end

  describe "#destroy" do

    it "does nothing if the directory does not exist" do
      subject.destroy
      tmpdir.must_be :exist?
      subject.wont_be :changed?
    end

    it "deletes the directory" do
      path.mkdir
      subject.destroy
      path.wont_be :exist?
      tmpdir.must_be :exist?
      subject.changes.must_include "deleted"
    end

    it "deletes recursively" do
      path.mkdir
      (path + "foo").mkdir
      subject.destroy
    end
  end
end
