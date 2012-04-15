require 'helper'

describe Config::Log do

  let(:stream) { StringIO.new }

  subject { Config::Log.new(stream) }

  it "appends" do
    subject << "one"
    subject << "two"
    stream.string.must_equal <<-STR
one
two
    STR
  end

  it "indents" do
    subject << "a"
    subject.indent do
      subject << "b"
      subject.indent do
        subject << "c"
      end
      subject << "d"
    end
    subject << "e"
    stream.string.must_equal <<-STR
a
  b
    c
  d
e
    STR
  end

  it "indents any amount" do
    subject.indent(2) do
      subject << "ok"
    end
    stream.string.must_equal "    ok\n"
  end

  it "handles multiline input with indent" do
    subject.indent do
      subject << "one\ntwo"
    end
    stream.string.must_equal <<-STR
  one
  two
    STR
  end
end
