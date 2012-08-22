require 'helper'

describe String, "#dent" do

  it "de-dents a multi-line string where the indent level is on the first line" do
    str = <<-STR
      One
        Two
          Three
    STR
    str.dent.must_equal "One\n  Two\n    Three\n"
  end

  it "de-dents a multi-line string where the shortest indent is on a later line" do
    str = <<-STR
          One
        Two
      Three
    STR
    str.dent.must_equal "    One\n  Two\nThree\n"
  end

  it "de-dents a single-line string" do
    str = "  Hello"
    str.dent.must_equal "Hello"
  end

  it "does not replace whitespace within the string" do
    str = "  Hello  World  "
    str.dent.must_equal "Hello  World  "
  end

  it "does nothing if there is no indent" do
    str = "Hello"
    str.dent.must_equal "Hello"
  end

  it "matches the trailing newlines of the original string" do
    "a".dent.must_equal "a"
    "a\n".dent.must_equal "a\n"
    "a\n\n".dent.must_equal "a\n\n"
  end

  it "initial blank lines don't cause denting" do
    str = <<-STR

      Hello
      World
    STR
    str.dent.must_equal "\n      Hello\n      World\n"
  end
end
