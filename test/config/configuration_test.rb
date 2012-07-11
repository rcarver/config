require 'helper'

describe Config::Configuration do

  subject { Config::Configuration.new }

  specify "#to_s" do
    subject.to_s.must_equal "<Configuration>"
  end

  it "allows groups to be defined and accessed" do
    subject.set_group(:test, key: 123)
    subject.test.must_be_instance_of Config::Configuration::Group
    subject[:test].must_be_instance_of Config::Configuration::Group
  end

  it "raises an error if you access an unknown group" do
    proc { subject.nothing }.must_raise Config::Configuration::UnknownGroup
    proc { subject[:nothing] }.must_raise Config::Configuration::UnknownGroup
  end

  it "does not allow a group to be redefined" do
    subject.set_group(:test, key: 123)
    proc { subject.set_group(:test, key: 123) }.must_raise Config::Configuration::DuplicateGroup
  end

  it "can be merged" do
    a = Config::Configuration.new
    a.set_group(:group1, key1: 123, key2: 456, key3: 111)
    a.set_group(:group2, key1: 123)

    b = Config::Configuration.new
    b.set_group(:group1, key1: 999, key2: 456, key4: 222)
    b.set_group(:group3, key1: 123)

    c = a + b

    c.group1.key1.must_equal 999
    c.group1.key2.must_equal 456
    c.group1.key3.must_equal 111
    c.group1.key4.must_equal 222
    c.group2.key1.must_equal 123
    c.group3.key1.must_equal 123
  end
end

describe Config::Configuration::Group do

  let(:hash) { {} }

  subject { Config::Configuration::Group.new(:test, hash) }

  before do
    hash[:name] = "ok"
    hash[:value] = 123
    hash[:other] = nil
  end

  it "allows hash access" do
    subject[:name].must_equal "ok"
    subject[:value].must_equal 123
    subject[:other].must_equal nil
  end

  it "allows dot access" do
    subject.name.must_equal "ok"
    subject.value.must_equal 123
    subject.other.must_equal nil
  end

  it "raises an error if you access a nonexistent key" do
    proc { subject[:foo] }.must_raise Config::Configuration::UnknownVariable
    proc { subject.foo }.must_raise Config::Configuration::UnknownVariable
  end

  it "makes sure you don't call it wrong" do
    proc { subject.name("ok") }.must_raise ArgumentError
  end

  it "logs when a variable is used" do
    subject.name
    log_string.must_equal "Read test.name => \"ok\"\n"
  end

  it "does not log a bad key" do
    proc { subject.foo }.must_raise Config::Configuration::UnknownVariable
    log_string.must_be_empty
  end
end

