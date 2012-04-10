require 'helper'

module BlueprintTest

  class << self
    attr_accessor :value
  end

  # A pattern that sets a variable.
  class Test < Config::Pattern
    desc "The name"
    key  :name
    desc "The value"
    attr :value
    def create
      BlueprintTest.value << [name, value]
    end
  end

  describe Config::Blueprint do

    before do
      BlueprintTest.value = []
    end

    subject { Config::Blueprint.from_string("test", code) }

    def log_string
      stream = StringIO.new
      subject.log = Config::Log.new(stream)
      subject.accumulate
      subject.execute
      stream.string
    end

    describe "in general" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "one"
            t.value = 1
          end
          add BlueprintTest::Test do |t|
            t.name = "two"
            t.value = 2
          end
        STR
      }

      it "has a name" do
        subject.to_s.must_equal "Blueprint test"
      end

      it "accumulates the patterns" do
        accumulation = subject.accumulate
        accumulation.size.must_equal 2
      end

      it "executes the patterns" do
        subject.accumulate
        subject.validate
        BlueprintTest.value.must_equal []
        subject.execute
        BlueprintTest.value.must_equal [
          ["one", 1],
          ["two", 2]
        ]
      end

      it "logs what happened" do
        log_string.must_equal <<-STR
Accumulate Blueprint test
Validate Blueprint test
Resolve Blueprint test
Execute Blueprint test
  [create] BlueprintTest::Test name:one
  [create] BlueprintTest::Test name:two
        STR
      end
    end

    describe "with invalid patterns" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "the test"
            # no value set
          end
        STR
      }

      it "detects validation errors" do
        subject.accumulate
        proc { subject.validate }.must_raise Config::Core::Executor::ValidationError
      end
    end

    describe "with conflicting patterns" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "the test"
            t.value = 1
          end
          add BlueprintTest::Test do |t|
            t.name = "the test"
            t.value = 2
          end
        STR
      }

      it "detects conflict errors" do
        subject.accumulate
        proc { subject.validate }.must_raise Config::Core::Executor::ConflictError
      end
    end

    describe "with duplicate patterns" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "the test"
            t.value = "ok"
          end
          add BlueprintTest::Test do |t|
            t.name = "the test"
            t.value = "ok"
          end
        STR
      }

      it "only runs one pattern" do
        subject.accumulate
        subject.validate
        BlueprintTest.value.must_equal []
        subject.execute
        BlueprintTest.value.must_equal [
          ["the test", "ok"]
        ]
      end

      it "logs what happened" do
        log_string.must_equal <<-STR
Accumulate Blueprint test
Validate Blueprint test
Resolve Blueprint test
Execute Blueprint test
  [create] BlueprintTest::Test name:the test
  [skip] BlueprintTest::Test name:the test
        STR
      end
    end
  end
end
