require 'helper'

describe Config::Core::Configuration do

  subject { Config::Core::Configuration.new }

  specify "#to_s" do
    subject.to_s.must_equal "<Configuration>"
  end

  it "allows groups to be defined and accessed" do
    subject.set_group(:test, key: 123)
    subject.test.must_be_instance_of Config::Core::Configuration::Group
    subject[:test].must_be_instance_of Config::Core::Configuration::Group
  end

  it "rasies an error if you access an unknown group" do
    proc { subject.nothing }.must_raise Config::Core::Configuration::UnknownGroup
    proc { subject[:nothing] }.must_raise Config::Core::Configuration::UnknownGroup
  end

  it "does not allow a group to be redefined" do
    subject.set_group(:test, key: 123)
    proc { subject.set_group(:test, key: 123) }.must_raise Config::Core::Configuration::DuplicateGroup
  end
end

describe Config::Core::Configuration::Group do

  let(:hash) { {} }

  subject { Config::Core::Configuration::Group.new(:test, hash) }

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
    proc { subject[:foo] }.must_raise Config::Core::Configuration::UnknownVariable
    proc { subject.foo }.must_raise Config::Core::Configuration::UnknownVariable
  end

  it "makes sure you don't call it wrong" do
    proc { subject.name("ok") }.must_raise ArgumentError
  end

  it "logs when a variable is used" do
    subject.name
    log_string.must_equal "Read test.name => \"ok\"\n"
  end

  it "does not log a bad key" do
    proc { subject.foo }.must_raise Config::Core::Configuration::UnknownVariable
    log_string.must_be_empty
  end
end

