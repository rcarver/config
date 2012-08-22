require 'helper'

module PatternIntegrationTest
  describe Config::Pattern do

    class TestPattern < Config::Pattern

      desc "The name"
      key :name

      desc "The value"
      attr :value

      def describe
        "TestPattern:#{name}"
      end

      def call
        @called = true
      end

      attr_reader :called
      attr_reader :result

      def create
        @result = "created"
      end

      def destroy
        @result = "destroyed"
      end
    end

    let(:accumulation) { Config::Core::Accumulation.new }

    subject { TestPattern.new }

    before do
      subject.accumulation = accumulation
      subject.name = "test"
      subject.value = 123
    end

    it "has a useful #to_s" do
      subject.to_s.must_equal %{[TestPattern:test]}
    end

    it "has a useful #inspect" do
      subject.inspect.must_equal %(<PatternIntegrationTest::TestPattern {"name":"test","value":123}>)
    end

    it "can marshall" do
      dump = Marshal.dump(subject)
      restore = Marshal.restore(dump)
      restore.must_equal subject
    end

    describe "#add" do

      before do
        subject.add TestPattern do |x|
          x.name = "sub-name"
          x.value = "sub-value"
        end
      end

      it "accumulates one pattern" do
        accumulation.size.must_equal 1
      end

      let(:child_pattern) { accumulation.to_a.first }

      it "calls the child pattern" do
        child_pattern.called.must_equal true
      end

      it "assigns itself to the child pattern" do
        child_pattern.parent.must_equal subject
      end

      it "configures the child pattern" do
        child_pattern.name.must_equal "sub-name"
        child_pattern.value.must_equal "sub-value"
      end

      it "logs the patterns that are added" do
        log_string.must_equal <<-STR.dent
          + PatternIntegrationTest::TestPattern
            [TestPattern:sub-name]
        STR
      end
    end

    describe "#add is recursive" do

      it "recursively calls patterns until all are found" do
        skip "this is useful but not testable right now"

        called = []

        z, a, b, c, d, e, f, g = nil

        g = lambda       { called << "g"; accumulation << e }
          e = lambda     { called << "e" }
        f = lambda       { called << "f"; accumulation << d }
          d = lambda     { called << "d"; accumulation << c; accumulation << a }
            c = lambda   { called << "c"; accumulation << b }
              b = lambda { called << "b" }
            a = lambda   { called << "a"; accumulation << z }
              z = lambda { called << "z" }

        accumulation << g
        accumulation << f

        g.call
        f.call

        called.size.must_equal 8
        called.must_equal %w(g e f d c b a z)
        accumulation.to_a.must_equal [g, e, f, d, c, b, a, z]
      end
    end

    describe "#execute" do

      it "creates by default" do
        subject.execute
        subject.result.must_equal "created"
      end
      it "creates" do
        subject.run_mode = :create
        subject.execute
        subject.result.must_equal "created"
      end
      it "destroys" do
        subject.run_mode = :destroy
        subject.execute
        subject.result.must_equal "destroyed"
      end
      it "skips" do
        subject.run_mode = :skip
        subject.execute
        subject.result.must_equal nil
      end
    end

    describe "#error_messages" do

      it "includes attribute errors" do
        subject.value = nil
        subject.error_messages.wont_be_empty
      end
    end
  end
end
