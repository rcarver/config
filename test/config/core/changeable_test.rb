require 'helper'

describe Config::Core::Changeable do

  let(:klass) {
    Class.new do
      include Config::Core::Changeable
      include Config::Core::Loggable
    end
  }

  subject { klass.new }

  it "accumulates messages when a change occurs" do
    subject.changes << "first thing"
    subject.changes << "second thing"
    subject.changes.to_a.must_equal ["first thing", "second thing"]
  end

  it "writes to the log when changes occur" do
    subject.changes << "first thing"
    subject.changes << "second thing"
    log_string.must_equal <<-STR
  first thing
  second thing
    STR
  end

  it "knows if a change occurred" do
    subject.changes.include?("this").wont_equal true
    subject.changes << "this"
    subject.changes.include?("this").must_equal true
  end

  it "tracks changed state" do
    subject.changes.must_be :empty?
    subject.wont_be :changed?
    subject.changes << "thing"
    subject.changes.wont_be :empty?
    subject.must_be :changed?
  end
end
