require 'helper'
require 'tempfile'

describe Config::Core::Accumulation do

  subject { Config::Core::Accumulation.new }

  describe "#<<" do

    let(:pattern) { MiniTest::Mock.new }

    it "appends the pattern and calls it" do

      #pattern.expect(:call, nil)

      subject << pattern
      subject.to_a.must_equal [pattern]

      #pattern.verify
    end
  end

  #describe "#add" do

    #let(:pattern_class) { MiniTest::Mock.new }
    #let(:pattern) { MiniTest::Mock.new }
    #let(:parent) { MiniTest::Mock.new }

    #before do
      #pattern_class.expect(:new, pattern)
      #pattern.expect(:accumulation=, nil, [subject])
      #pattern.expect(:parent=, nil, [parent])
    #end

    #after do
      #pattern_class.verify
      #pattern.verify
    #end

    #it "instantiates the pattern" do
      #subject.add_pattern(parent, pattern_class)
    #end

    #it "instantiates the pattern with a block" do
      #pattern.expect(:touch, nil)
      #subject.add_pattern parent, pattern_class do |p|
        #p.touch
      #end
    #end

    #it "stores the instantiated pattern" do
      #subject.add_pattern(parent, pattern_class)
      #subject.to_a.must_equal [pattern]
    #end
  #end

  describe "serialization" do

    let(:patterns) { ["one", "two"] }

    subject { Config::Core::Accumulation.new(patterns) }

    it "serializes to a String" do
      subject.serialize.must_be_instance_of String
    end

    it "instantiates from a String" do
      serialize = subject.serialize
      restore = Config::Core::Accumulation.from_string(serialize)
      subject.must_equal restore
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
  end
end
