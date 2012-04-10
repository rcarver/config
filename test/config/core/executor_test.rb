require 'helper'

describe Config::Core::Executor do

  let(:accumulation) { [] }

  subject { Config::Core::Executor.new(accumulation) }

  describe "#accumulate" do

    it "recursively calls patterns until all are found" do
      called = []

      a = lambda { called << "a" }
      b = lambda { called << "b"; accumulation << a }
      c = lambda { called << "c" }
      d = lambda { called << "d"; accumulation << c; accumulation << b }
      e = lambda { called << "e" }
      f = lambda { called << "f"; accumulation << d }
      g = lambda { called << "g"; accumulation << e }

      accumulation.concat [f, g]

      subject.accumulate

      called.must_equal %w(f g d e c b a)
      accumulation.must_equal [f, g, d, e, c, b, a]
    end
  end

  describe "#validate!" do

    let(:pattern) { MiniTest::Mock.new }

    before do
      accumulation << pattern
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
      }.must_raise Config::Core::Executor::ValidationError
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
      accumulation << a
      accumulation << c
      accumulation << d
      proc { subject.resolve! }.must_raise Config::Core::Executor::ConflictError
    end

    it "marks duplicate patterns as skipped" do
      accumulation << a
      accumulation << b
      accumulation << d
      subject.resolve!
      a.run_mode.must_equal nil
      b.run_mode.must_equal :skip
      d.run_mode.must_equal nil
    end
  end

  describe "#execute" do

    it "tells each pattern to execute" do
      a = MiniTest::Mock.new
      b = MiniTest::Mock.new

      accumulation.concat [a, b]

      a.expect(:execute, nil)
      b.expect(:execute, nil)

      subject.execute

      a.verify
      b.verify
    end
  end
end

