require 'helper'

describe Config::Patterns do

  let(:helper_class) {
    Class.new do
      include Config::Patterns

      attr_reader :klass

      def mock
        @mock ||= MiniTest::Mock.new
      end

      def add(klass)
        @klass = klass
        yield mock
      end
    end
  }

  subject { helper_class.new }

  let(:mock) { subject.mock }

  after do
    subject.klass.must_equal pattern
    mock.verify
  end

  describe "#file" do

    let(:pattern) { Config::Patterns::File }

    it "sets the path and adds the pattern" do
      mock.expect(:path=, nil, ["/tmp/file"])
      subject.file "/tmp/file", false
    end

    it "calls the block" do
      mock.expect(:path=, nil, ["/tmp/file"])
      mock.expect(:other=, nil, ["value"])
      subject.file "/tmp/file", false do |f|
        f.other = "value"
      end
    end

    it "allows simple template configuration" do
      mock.expect(:path=, nil, ["/tmp/file"])
      subject.file "/tmp/file", true do |f|
        f.must_be_instance_of Config::Patterns::FileTemplate
      end
    end
  end

  describe "#dir" do

    let(:pattern) { Config::Patterns::Directory }

    it "sets the path and adds the pattern" do
      mock.expect(:path=, nil, ["/tmp"])
      subject.dir "/tmp"
    end

    it "calls the block" do
      mock.expect(:path=, nil, ["/tmp"])
      mock.expect(:other=, nil, ["value"])
      subject.dir "/tmp" do |d|
        d.other = "value"
      end
    end
  end

  describe "#chown" do

    let(:pattern) { Config::Patterns::Chown }

    it "sets the path and adds the pattern" do
      mock.expect(:path=, nil, ["/tmp"])
      subject.chown "/tmp"
    end

    it "sets the path and applies owner and group options" do
      mock.expect(:path=, nil, ["/tmp"])
      mock.expect(:owner=, nil, ["root"])
      mock.expect(:group=, nil, ["admin"])
      subject.chown "/tmp", "root", "admin"
    end

    it "calls the block" do
      mock.expect(:path=, nil, ["/tmp"])
      mock.expect(:other=, nil, ["value"])
      subject.chown "/tmp" do |d|
        d.other = "value"
      end
    end
  end

  describe "#chmod" do

    let(:pattern) { Config::Patterns::Chmod }

    it "sets the path and adds the pattern" do
      mock.expect(:path=, nil, ["/tmp"])
      subject.chmod "/tmp"
    end

    it "sets the path and applies the mode" do
      mock.expect(:path=, nil, ["/tmp"])
      mock.expect(:mode=, nil, [0755])
      subject.chmod "/tmp", 0755
    end

    it "calls the block" do
      mock.expect(:path=, nil, ["/tmp"])
      mock.expect(:other=, nil, ["value"])
      subject.chmod "/tmp" do |d|
        d.other = "value"
      end
    end
  end

  describe "#script" do

    let(:pattern) { Config::Patterns::Script }

    it "sets the name and adds the pattern, and sets the interpreter to sh" do
      mock.expect(:name=, nil, ["the test"])
      mock.expect(:code_exec=, nil, ["sh"])
      subject.script "the test"
    end

    it "calls the block" do
      mock.expect(:name=, nil, ["the test"])
      mock.expect(:other=, nil, ["value"])
      mock.expect(:code_exec=, nil, ["sh"])
      subject.script "the test" do |s|
        s.other = "value"
      end
    end
  end

  describe "#bash" do

    let(:pattern) { Config::Patterns::Bash }

    it "sets the name and adds the pattern" do
      mock.expect(:name=, nil, ["the test"])
      subject.bash "the test"
    end

    it "calls the block" do
      mock.expect(:name=, nil, ["the test"])
      mock.expect(:other=, nil, ["value"])
      subject.bash "the test" do |s|
        s.other = "value"
      end
    end
  end

  describe "#package" do

    let(:pattern) { Config::Patterns::Package }

    it "sets the name and adds the pattern" do
      mock.expect(:name=, nil, ["nginx"])
      subject.package "nginx"
    end

    it "sets the name, version and adds the pattern" do
      mock.expect(:name=, nil, ["nginx"])
      mock.expect(:version=, nil, ["1.0"])
      subject.package "nginx", "1.0"
    end

    it "calls the block" do
      mock.expect(:name=, nil, ["nginx"])
      mock.expect(:other=, nil, ["1.1"])
      subject.package "nginx" do |s|
        s.other = "1.1"
      end
    end
  end
end

describe Config::Patterns::FileTemplate do

  let(:pattern) { MiniTest::Mock.new }
  let(:context) { MiniTest::Mock.new }
  let(:source_file) { "/project/patterns/topic/pattern.rb" }

  subject { Config::Patterns::FileTemplate.new(pattern, context, source_file) }

  it "assigns template details" do
    pattern.expect(:template_path=, nil, ["/project/patterns/topic/templates/template.erb"])
    pattern.expect(:template_context=, nil, [context])
    subject.template = "template.erb"
  end

  it "assigns template details with a subdir" do
    pattern.expect(:template_path=, nil, ["/project/patterns/topic/templates/subdir/template.erb"])
    pattern.expect(:template_context=, nil, [context])
    subject.template = "subdir/template.erb"
  end

  it "delegates everything else" do
    pattern.expect(:public_send, "value", [:foo, "a", "b"])
    subject.foo("a", "b").must_equal "value"
  end
end
