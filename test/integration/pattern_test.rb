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
        add self.class do |x|
          x.name = "sub-#{name}"
          x.value = "sub-#{value}"
        end
      end

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

    describe "#call" do

      before do
        subject.call
      end

      let(:child_pattern) { accumulation.to_a.first }

      it "accumulates the child patterns" do
        accumulation.size.must_equal 1
      end
      it "assigns itself to the child pattern" do
        child_pattern.parent.must_equal subject
      end
      it "configures the child pattern" do
        child_pattern.name.must_equal "sub-test"
        child_pattern.value.must_equal "sub-123"
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
