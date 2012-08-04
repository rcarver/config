require 'helper'

describe Config::Configuration::Group do

  let(:hash) { {} }

  subject { Config::Configuration::Group.new("fake level", :test, hash) }

  before do
    hash[:name] = "ok"
    hash[:value] = 123
    hash[:other] = nil
  end

  specify "#_level_name" do
    subject._level_name.must_equal "fake level"
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

  it "allows the existence of a key to be tested" do
    subject.defined?(:name).must_equal true
    subject.defined?(:foo).must_equal false
    subject.name?.must_equal true
    subject.foo?.must_equal false
  end

  it "makes sure you don't call it wrong" do
    proc { subject.name("ok") }.must_raise ArgumentError
  end
end



