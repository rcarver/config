require 'helper'
require 'tempfile'

describe Config::Core::Execution do

  let(:pattern_class) {
    Class.new do
      include Config::Core::Marshalable
      def attributes
        { :name => "test", :value => "ok" }
      end
    end
  }

  describe "in general" do

    let(:patterns) { ["one", "two"] }

    subject { Config::Core::Execution.new(patterns) }

    it "enumerates patterns" do
      subject.to_a.must_equal ["one", "two"]
    end

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
      restore = Config::Core::Execution.from_string(serialize)
      subject.must_equal restore
    end

    it "instantiates from a File" do
      file = Tempfile.new('serialize')
      begin
        subject.write_to_file(file.path)
        file.flush
        restore = Config::Core::Execution.from_file(file.path)
        subject.must_equal restore
      ensure
        file.close!
      end
    end
  end

  describe "subtract another execution" do

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

    let(:previous_execution) {
      Config::Core::Execution.new([a, b, c])
    }

    subject {
      Config::Core::Execution.new([a, b])
    }

    it "returns a new execution containing the extra patterns" do
      (previous_execution - subject).must_be_instance_of Config::Core::Execution
      (previous_execution - subject).to_a.must_equal [c]
    end
  end
end
