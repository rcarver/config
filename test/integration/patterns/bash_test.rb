require 'helper'

describe Config::Patterns::Bash do

  subject { Config::Patterns::Bash.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:name]
  end

  specify "validity" do
    subject.name = "say ok"
    subject.code = "echo ok"
    subject.attribute_errors.must_be_empty
  end

  specify "#to_s" do
    subject.name = "say ok"
    subject.to_s.must_equal %(Bash "say ok")
  end
end

describe "filesystem", Config::Patterns::Bash do

  subject { Config::Patterns::Bash.new }

  def call_pattern
    subject.accumulation = Config::Core::Accumulation.new
    subject.prepare
    subject.call
    subject.accumulation.to_a
  end

  describe "#call" do

    before do
      subject.code = <<-STR.dent
        echo 123
      STR
      subject.reverse = <<-STR.dent
        echo 321
      STR
    end

    it "runs a bash script with good defaults" do
      patterns = call_pattern
      patterns.size.must_equal 1
      patterns.first.code_exec.must_equal "bash"
      patterns.first.code_args.must_equal ["-e", "-u"]
    end
  end
end
