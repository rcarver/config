require 'helper'

describe Config::Spy::Configuration do

  subject { Config::Spy::Configuration.new }

  specify "#to_s" do
    subject.to_s.must_equal "<Spy Configuration>"
  end

  specify "#[]" do
    subject[:foo].must_be_instance_of Config::Spy::Configuration::Group
  end

  specify "string keys are not allowed for #[]" do
    proc { subject["ok"] }.must_raise ArgumentError
  end

  specify "#method_missing" do
    subject.foo.must_be_instance_of Config::Spy::Configuration::Group
  end

  it "does not log when a group is accessed" do
    subject.foo
    log_string.must_equal ""
  end

  it "accumulates the groups that have been accessed" do
    subject.get_accessed_groups.size.must_equal 0
    subject[:foo]
    subject.foo
    subject.bar
    subject.get_accessed_groups.size.must_equal 2
  end
end

describe Config::Spy::Configuration::Group do

  subject { Config::Spy::Configuration::Group.new(:sample) }

  specify "#[]" do
    subject[:ok].must_equal "fake:sample.ok"
  end

  specify "string keys are not allowed for #[]" do
    proc { subject["ok"] }.must_raise ArgumentError
  end

  specify "#method_missing" do
    subject.ok.must_equal "fake:sample.ok"
  end

  it "logs when keys are accessed" do
    subject.ok
    log_string.must_equal %(Read sample.ok => "fake:sample.ok"\n)
  end

  it "accumulates the keys that have been accessed" do
    subject[:foo]
    subject.foo
    subject.bar
    subject.get_accessed_keys.must_equal [:foo, :bar]
  end

  specify "#to_s" do
    subject.to_s.must_equal "fake:sample"
  end

  it "behaves like a string" do
    String(subject).must_equal "fake:sample"
  end
end
