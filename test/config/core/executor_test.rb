require 'helper'

describe Config::Core::Executor do

  let(:accumulation) { [] }

  subject { Config::Core::Executor.new(accumulation) }

  describe "#accumulate" do

    it "recursively calls patterns until all are found" do
      called = []

      a, b, c, d, e, f, g = nil

      g = lambda       { called << "g"; accumulation << e }
        e = lambda     { called << "e" }
      f = lambda       { called << "f"; accumulation << d }
        d = lambda     { called << "d"; accumulation << c; accumulation << b }
          c = lambda   { called << "c" }
          b = lambda   { called << "b"; accumulation << a }
            a = lambda { called << "a" }

      accumulation.concat [g, f]

      subject.accumulate

      called.size.must_equal 7
      called.must_equal %w(g e f d c b a)
      accumulation.must_equal [g, e, f, d, c, b, a]
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
      pattern.expect(:validate, [])
      pattern.expect(:error_messages, [])
      subject.validate!
    end

    it "raises a ValidationError if there are errors" do
      pattern.expect(:validate, [])
      pattern.expect(:error_messages, ["boo"])
      proc {
        subject.validate!
      }.must_raise Config::Core::ValidationError
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

    # a & c are in conflict
    # a & b are equal
    let(:a) { pattern_class.new(:a, 1) }
    let(:b) { pattern_class.new(:a, 1) }
    let(:c) { pattern_class.new(:a, 2) }
    let(:d) { pattern_class.new(:b, 1) }

    it "raises a ConflictError if conflicting patterns are found" do
      accumulation << a
      accumulation << c
      accumulation << d
      proc { subject.resolve! }.must_raise Config::Core::ConflictError
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

    let(:a) { MiniTest::Mock.new }
    let(:b) { MiniTest::Mock.new }
    let(:c) { MiniTest::Mock.new }

    after do
      a.verify
      b.verify
      c.verify
    end

    describe "in general" do

      it "executes each pattern" do
        accumulation.concat [a, b, c]

        a.expect(:execute, nil)
        b.expect(:execute, nil)
        c.expect(:execute, nil)

        subject.execute
      end
    end

    describe "with a previous accumulation" do

      it "destroys the missing patterns" do

        # The current patterns are [a, b]
        accumulation.concat [a, b]

        # The previous accumulation included [c], so we will now destroy it.
        previous_accumulation = MiniTest::Mock.new
        previous_accumulation.expect(:-, [c], [accumulation])
        subject.previous_accumulation = previous_accumulation

        a.expect(:execute, nil)
        b.expect(:execute, nil)

        c.expect(:run_mode=, nil, [:destroy])
        c.expect(:execute, nil)

        subject.execute
      end
    end
  end
end

