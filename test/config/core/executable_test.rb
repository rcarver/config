require 'helper'

describe Config::Core::Executable do

  let(:klass) {
    Class.new do
      include Config::Core::Executable

      attr_reader :result

      def create
        @result = "created"
      end

      def destroy
        @result = "destroyed"
      end
    end
  }

  subject { klass.new }

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

    it "does not support other run modes" do
      subject.run_mode = :foobar
      proc { subject.execute }.must_raise ArgumentError
    end
  end
end

