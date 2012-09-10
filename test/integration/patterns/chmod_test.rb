require 'helper'

describe Config::Patterns::Chmod do

  subject { Config::Patterns::Chmod.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:path]
  end

  specify "validity" do
    subject.path = "/tmp/file.rb"
    subject.mode = 0755
    subject.attribute_errors.must_be_empty
  end

  describe "#to_s" do

    before do
      subject.path = "/tmp/file"
    end

    specify "without a mode" do
      subject.to_s.must_equal "chmod /tmp/file"
    end

    specify "normally" do
      subject.mode = 0755
      subject.to_s.must_equal "chmod 0755 /tmp/file"
    end

    specify "recursively" do
      subject.mode = 0755
      subject.recursive = true
      subject.to_s.must_equal "chmod -R 0755 /tmp/file"
    end
  end

  describe "handling octal numbers" do

    specify "given nil" do
      subject.mode = nil
      subject.mode_octal.must_equal nil
      subject.mode_string.must_equal nil
    end

    specify "given an integer" do
      subject.mode = 0755
      subject.mode_octal.must_equal 0755
      subject.mode_string.must_equal "0755"
    end

    specify "given an integer with a sticky bit" do
      subject.mode = 01755
      subject.mode_octal.must_equal 01755
      subject.mode_string.must_equal "1755"
    end

    specify "given a string" do
      subject.mode = "755"
      subject.mode_octal.must_equal 0755
      subject.mode_string.must_equal "0755"
    end

    specify "given a string with a leading zero" do
      subject.mode = "0755"
      subject.mode_octal.must_equal 0755
      subject.mode_string.must_equal "0755"
    end
  end
end

describe "filesystem", Config::Patterns::Chmod do

  subject { Config::Patterns::Chmod.new }

  let(:path) { tmpdir + "test.txt" }
  let(:fu) { MiniTest::Mock.new }

  before do
    path.open("w") { |f| f.print "ok" }
    subject.path = path.to_s
    subject.fu = fu
  end

  def execute(run_mode)
    subject.prepare
    subject.public_send(run_mode)
  end

  describe "#create" do

    it "sets the mode" do
      subject.mode = 0755

      fu.expect(:chmod, nil, [0755, path.to_s])

      execute :create
      subject.changes.to_a.must_equal ["Set mode to 0755"]
    end

    it "sets the mode recursively" do
      subject.mode = 0755
      subject.recursive = true

      fu.expect(:chmod_R, nil, [0755, path.to_s])

      execute :create
      subject.changes.to_a.must_equal ["Set mode to 0755"]
    end

    it "does nothing if the correct mode is already set" do
      current_mode = ::File.stat(path).mode & 07777

      subject.mode = current_mode

      execute :create
      subject.changes.to_a.must_equal []
    end
  end
end
