require 'helper'

describe String, "#dent" do

  it "indents a multi-line string" do
    str = <<-STR
      One
        Two
          Three
    STR
    str.dent.must_equal "One\n  Two\n    Three\n"
  end

  it "indents a single-line string" do
    str = "  Hello"
    str.dent.must_equal "Hello"
  end

  it "does not replace whitespace within the string" do
    str = "  Hello  World  "
    str.dent.must_equal "Hello  World  "
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
