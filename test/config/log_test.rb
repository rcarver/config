require 'helper'

describe Config::Log do

  let(:stream) { StringIO.new }

  subject { Config::Log.new(stream) }

  it "appends" do
    subject << "one"
    subject << "two"
    stream.string.must_equal <<-STR.dent
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
    stream.string.must_equal <<-STR.dent
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

  it "colorizes" do
    subject.colorize("hello", :green).must_equal "\e[32mhello\e[0m"
  end

  it "does not colorize when color is set to false" do
    subject.color = false
    subject.colorize("hello", :green).must_equal "hello"
  end

  it "knows if color is enabled" do
    subject.must_be :color?
    subject.color = false
    subject.wont_be :color?
  end
end
