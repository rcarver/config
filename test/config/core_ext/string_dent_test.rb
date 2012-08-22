require 'helper'

describe String, "#dent" do

  it "outdents" do
    str = "  Hello"
    str.dent.must_equal "Hello"
  end

  it "in-dents" do
    str = "Hello"
    str.dent(2).must_equal "  Hello"
  end

  it "outdents and in-dents" do
    str = <<-STR.dent(2)
      One
        Two
    STR
    str.dent(2).must_equal "  One\n    Two\n"
  end
end

describe String, "#outdent" do

  it "outdents a multi-line string where the indent level is on the first line" do
    str = <<-STR
      One
        Two
          Three
    STR
    str.outdent.must_equal "One\n  Two\n    Three\n"
  end

  it "outdents a multi-line string where the shortest indent is on a later line" do
    str = <<-STR
          One
        Two
      Three
    STR
    str.outdent.must_equal "    One\n  Two\nThree\n"
  end

  it "outdents a single-line string" do
    str = "  Hello"
    str.outdent.must_equal "Hello"
  end

  it "does not replace whitespace within the string" do
    str = "  Hello  World  "
    str.outdent.must_equal "Hello  World  "
  end

  it "does nothing if there is no indent" do
    str = "Hello"
    str.outdent.must_equal "Hello"
  end

  it "matches the trailing newlines of the original string" do
    "a".outdent.must_equal "a"
    "a\n".outdent.must_equal "a\n"
    "a\n\n".outdent.must_equal "a\n\n"
  end

  it "initial blank lines don't cause denting" do
    str = <<-STR

      Hello
      World
    STR
    str.outdent.must_equal "\n      Hello\n      World\n"
  end
end

describe String, "#indent" do

  it "indents each line of a multiline string" do
    str = <<-STR
One
  Two
    STR
    str.indent(2).must_equal "  One\n    Two\n"
  end

  it "indents with a string" do
    str = "Hello"
    str.indent("x ").must_equal "x Hello"
  end

  it "indents with an integer" do
    str = "Hello"
    str.indent(4).must_equal "    Hello"
  end

  it "cannot indent with anything else" do
    str = "Hello"
    -> { str.indent(3.3) }.must_raise ArgumentError
  end

  it "matches the trailing newlines of the original string" do
    "a".indent(2).must_equal "  a"
    "a\n".indent(2).must_equal "  a\n"
    "a\n\n".indent(2).must_equal "  a\n\n"
  end

end
