require 'helper'
require 'tempfile'

describe Config::Core::Accumulation do

  subject { Config::Core::Accumulation.new }

  describe "#add" do

    let(:pattern_class) { MiniTest::Mock.new }
    let(:pattern) { MiniTest::Mock.new }
    let(:parent) { MiniTest::Mock.new }

    before do
      subject.current = parent
      pattern_class.expect(:new, pattern)
      pattern.expect(:accumulation=, nil, [subject])
      pattern.expect(:parent=, nil, [parent])
    end

    after do
      pattern_class.verify
      pattern.verify
    end

    it "instantiates the pattern" do
      subject.add(pattern_class)
    end

    it "instantiates the pattern with a block" do
      pattern.expect(:touch, nil)
      subject.add pattern_class do |p|
        p.touch
      end
    end

    it "stores the instantiated pattern" do
      subject.add(pattern_class)
      subject.to_a.must_equal [pattern]
    end
  end

  describe "serialization" do

    let(:patterns) { ["one", "two"] }

    subject { Config::Core::Accumulation.new(patterns) }

    it "serializes to a String" do
      subject.serialize.must_be_instance_of String
    end

    it "writes to a File" do
      file = Tempfile.new('serialize')
      begin
        subject.write_to_file(file.path)
        file.flush
        File.read(file).must_equal subject.serialize
      ensure
        file.close!
      end
    end

    it "instantiates from a String" do
      serialize = subject.serialize
      restore = Config::Core::Accumulation.from_string(serialize)
      subject.must_equal restore
    end

    it "instantiates from a File" do
      file = Tempfile.new('serialize')
      begin
        subject.write_to_file(file.path)
        file.flush
        restore = Config::Core::Accumulation.from_file(file.path)
        subject.must_equal restore
      ensure
        file.close!
      end
    end
  end

  describe "subtraction" do

    let(:pattern_class) {
      Class.new do

        def initialize(key)
          @key = key
        end

        attr_reader :key

        def eql?(other)
          other.key == key
        end

        def hash
          key.hash
        end
      end
    }

    let(:a) { pattern_class.new(:a) }
    let(:b) { pattern_class.new(:a) }
    let(:c) { pattern_class.new(:b) }

    let(:previous) { Config::Core::Accumulation.new([a, b, c]) }
    subject        { Config::Core::Accumulation.new([a, b]) }

    it "returns a new object containing the extra patterns" do
      (previous - subject).must_be_instance_of Config::Core::Accumulation
      (previous - subject).to_a.must_equal [c]
    end

    it "assigns the log" do
      subtraction = previous - subject
      subtraction.log.must_be_same_as previous.log
    end
  end
end
