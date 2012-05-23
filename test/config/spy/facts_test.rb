require 'helper'

describe Config::Spy::Facts do

  subject { Config::Spy::Facts.new }

  specify "#to_s" do
    subject.to_s.must_equal "<Spy Facts>"
  end

  specify "#[]" do
    subject[:foo].must_be_instance_of Config::Spy::Facts::Value
  end

  specify "#method_missing" do
    subject.foo.must_be_instance_of Config::Spy::Facts::Value
  end

  it "accumulates the chains that have been accessed" do
    subject.x.y
    subject.z
    subject.a
    subject.a.b
    subject["a"]["b"]["c"]
    subject.get_accessed_chains.must_equal [
      "a.b.c",
      "x.y",
      "z"
    ]
  end
end

describe Config::Spy::Facts::Value do

  subject { Config::Spy::Facts::Value.new([:one, :two]) }

  specify "#to_s" do
    subject.to_s.must_equal "fake:one.two"
  end

  specify "#[]" do
    subject[:three].must_be_instance_of Config::Spy::Facts::Value
    subject[:three].to_s.must_equal "fake:one.two.three"
  end

  specify "#method_missing" do
    subject.three.must_be_instance_of Config::Spy::Facts::Value
  end
end

