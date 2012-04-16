require 'helper'

describe Config::Core::Variables do

  let(:hash) { {} }

  subject { Config::Core::Variables.new(:test, hash) }

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
    proc { subject[:foo] }.must_raise Config::Core::Variables::UnknownVariable
    proc { subject.foo }.must_raise Config::Core::Variables::UnknownVariable
  end

  it "makes sure you don't call it wrong" do
    proc { subject.name("ok") }.must_raise ArgumentError
  end

  it "logs when a variable is used" do
    subject.name
    log_string.must_equal "Read test.name => \"ok\"\n"
  end

  it "does not log a bad key" do
    proc { subject.foo }.must_raise Config::Core::Variables::UnknownVariable
    log_string.must_be_empty
  end
end
