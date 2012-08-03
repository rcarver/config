require 'helper'

describe Config::Configuration::Group do

  let(:hash) { {} }

  subject { Config::Configuration::Group.new("fake level", :test, hash) }

  before do
    hash[:name] = "ok"
    hash[:value] = 123
    hash[:other] = nil
  end

  specify "#to_s" do
    subject.to_s.must_equal "<Configuration::Group :test (\"fake level\")>"
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

  it "allows the existence of a key to be tested" do
    subject.defined?(:name).must_equal true
    subject.defined?(:foo).must_equal false
    subject.name?.must_equal true
    subject.foo?.must_equal false
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



