require 'helper'

module BlueprintTest

  class << self
    attr_accessor :value
  end

  # A pattern that sets a variable.
  class Test < Config::Pattern
    desc "The name"
    attr :name
    def create
      BlueprintTest.value = name
    end
  end

  describe Config::Blueprint do

    before do
      BlueprintTest.value = nil
    end

    let(:definition) {
      <<-STR
        add BlueprintTest::Test do |t|
          t.name = "the test"
        end
      STR
    }

    subject { Config::Blueprint.from_string("test", definition) }

    it "has a name" do
      subject.to_s.must_equal "Blueprint test"
    end

    it "accumulates the patterns" do
      subject.call
      subject.accumulation.size.must_equal 1
    end

    it "executes the patterns" do
      subject.call
      BlueprintTest.value.must_equal nil
      subject.execute
      BlueprintTest.value.must_equal "the test"
    end
  end
end
