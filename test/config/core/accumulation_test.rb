require 'helper'

describe Config::Core::Accumulation do

  subject { Config::Core::Accumulation.new }

  describe "#add" do

    let(:pattern_class) { MiniTest::Mock.new }
    let(:pattern) { MiniTest::Mock.new }
    let(:parent) { MiniTest::Mock.new }

    before do
      subject.current = parent
      pattern_class.expect(:new, pattern, [subject])
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

  describe "#validate!" do

    let(:pattern) { MiniTest::Mock.new }

    before do
      subject << pattern
    end

    after do
      pattern.verify
    end

    it "does nothing if there are no errors" do
      pattern.expect(:error_messages, [])
      subject.validate!
    end

    it "raises a ValidationError if there are errors" do
      pattern.expect(:error_messages, ["boo"])
      proc {
        subject.validate!
      }.must_raise Config::Core::Accumulation::ValidationError
    end
  end

  describe "#resolve!" do

    let(:pattern_class) {
      Class.new do

        def initialize(key, value)
          @key = key
          @value = value
        end

        attr_reader :key, :value
        attr_accessor :run_mode

        def attributes
          { :key => key, :value => value }
        end

        def eql?(other)
          other.key == key
        end
        def ==(other)
          other.key == key && other.value == value
        end
        def hash
          key.hash
        end
        def conflict?(other)
          other.key == key && other.value != value
        end
      end
    }

    let(:a) { pattern_class.new(:a, 1) }
    let(:b) { pattern_class.new(:a, 1) }
    let(:c) { pattern_class.new(:a, 2) }
    let(:d) { pattern_class.new(:b, 1) }

    it "raises a ConflictError if conflicting patterns are found" do
      subject << a
      subject << c
      subject << d
      proc { subject.resolve! }.must_raise Config::Core::Accumulation::ConflictError
    end

    it "marks duplicate patterns as skipped" do
      subject << a
      subject << b
      subject << d
      subject.resolve!
      b.run_mode.must_equal :skip
    end
  end
end
