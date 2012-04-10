require 'helper'

describe Config::Core::Changeable do

  let(:klass) {
    Class.new do
      include Config::Core::Changeable
      include Config::Core::Loggable
      def to_s
        "Test Class"
      end
    end
  }

  subject { klass.new }

  let(:stream) { StringIO.new }

  before do
    subject.log = Config::Log.new(stream)
  end

  def log
    stream.string
  end

  it "accumulates messages when a change occurs" do
    subject.changed! "first thing"
    subject.changed! "second thing"
    log.must_equal <<-STR
  first thing
  second thing
    STR
  end

  it "tracks changed state" do
    subject.wont_be :changed?
    subject.changed! "ok"
    subject.must_be :changed?
  end
end
