require 'helper'

describe Config::Spy::Configuration do

  subject { Config::Spy::Configuration.new("spy level") }

  specify "#to_s" do
    subject.to_s.must_equal "<Spy Configuration spy level>"
  end

  specify "#_level_name" do
    subject._level_name.must_equal "spy level"
  end

  specify "#[]" do
  end

  it "allows groups to be accessed" do
    subject[:foo].must_be_instance_of Config::Spy::Configuration::Group
    subject.foo.must_be_instance_of Config::Spy::Configuration::Group
  end

  specify "string keys are not allowed for #[]" do
    proc { subject["ok"] }.must_raise ArgumentError
  end

  it "allows the existence of a group to be tested" do
    subject.defined?(:foo).must_equal true
    subject.foo?.must_equal true
  end

  specify "string keys are not allowed for #defined?" do
    proc { subject.defined?("ok") }.must_raise ArgumentError
  end

  it "accumulates the groups that have been accessed" do
    subject.get_accessed_groups.size.must_equal 0
    subject[:foo]
    subject.foo
    subject.bar
    subject.get_accessed_groups.size.must_equal 2
  end

  it "does not accumulate the keys that have been inquired about" do
    subject.foo?
    subject.get_accessed_groups.must_equal []
  end

  specify "#==" do
    subject.must_equal Config::Spy::Configuration.new("spy level")
    subject.wont_equal Config::Spy::Configuration.new("other level")
    subject.a
    subject.wont_equal Config::Spy::Configuration.new("spy level")
  end
end

describe Config::Spy::Configuration::Group do

  let(:parent) { nil }

  subject { Config::Spy::Configuration::Group.new("spy level", :sample, parent) }

  specify "#to_s" do
    subject.to_s.must_equal "spy:sample"
  end

  specify "#_level_name" do
    subject._level_name.must_equal "spy level"
  end

  it "behaves like a string" do
    String(subject).must_equal "spy:sample"
  end

  it "allows keys to be accessed" do
    subject[:ok].must_equal "spy:sample.ok"
    subject.ok.must_equal "spy:sample.ok"
  end

  it "allows the existence of a key to be tested" do
    subject.defined?(:ok).must_equal true
    subject.ok?.must_equal true
  end

  specify "string keys are not allowed for #[]" do
    proc { subject["ok"] }.must_raise ArgumentError
  end

  specify "string keys are not allowed for #defined?" do
    proc { subject.defined?("ok") }.must_raise ArgumentError
  end

  it "accumulates the keys that have been accessed" do
    subject[:foo]
    subject.foo
    subject.bar
    subject.get_accessed_keys.must_equal [:foo, :bar]
  end

  it "does not accumulate the keys that have been inquired about" do
    subject.foo?
    subject.get_accessed_keys.must_equal []
  end

  describe "with a parent" do

    let(:data) { { foo: 1 } }
    let(:parent) { Levels::Group.new("parent", :parent, data) }

    it "does not expose anything defined by the parent" do
      lambda { subject[:foo] }.must_raise Levels::UnknownKey
      subject[:bar]
    end

    it "does not define anything defined by the parent" do
      subject.defined?(:foo).must_equal false
      subject.defined?(:bar).must_equal true
    end
  end
end
