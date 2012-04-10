require 'helper'

describe Config::Core::Changeable do

  let(:klass) {
    Class.new do
      include Config::Core::Changeable
      def log
        @log ||= []
      end
      def to_s
        "Test Class"
      end
    end
  }

  subject { klass.new }

  it "accumulates messages when a change occurs" do
    subject.changed! "first thing"
    subject.changed! "second thing"
    subject.log.must_equal [
      "  [Test Class] first thing",
      "  [Test Class] second thing"
    ]
  end

  it "tracks changed state" do
    subject.wont_be :changed?
    subject.changed! "ok"
    subject.must_be :changed?
  end
end
