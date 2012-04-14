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
      subject.file "/tmp/file"
    end

    it "calls the block" do
      mock.expect(:path=, nil, ["/tmp/file"])
      mock.expect(:other=, nil, ["value"])
      subject.file "/tmp/file" do |f|
        f.other = "value"
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
      subject.dir "/tmp" do |f|
        f.other = "value"
      end
    end
  end
end
