require 'helper'

describe Config::Configuration::MergedGroup do

  let(:group1) { Config::Configuration::Group.new("g1", :test, a: 1, b: 2) }
  let(:group2) { Config::Configuration::Group.new("g2", :test, a: 9, c: 3) }

  subject { Config::Configuration::MergedGroup.new(:test, [group1, group2]) }

  it "allows hash access to any key" do
    subject[:a].must_equal 9
    subject[:b].must_equal 2
    subject[:c].must_equal 3
  end

  it "allows method access" do
    subject.a.must_equal 9
    subject.b.must_equal 2
    subject.c.must_equal 3
  end

  it "logs when a single-level, top level variable is used" do
    subject.b
    log_string.must_equal <<-STR
Read test.b => 2 from g1
    STR
  end

  it "logs when a single-level, lower level variable is used" do
    subject.c
    log_string.must_equal <<-STR
Read test.c => 3 from g2
    STR
  end

  it "logs when a multi-level variable is used" do
    subject.a
    log_string.must_equal <<-STR
Read test.a
  Skip 1 from g1
  Use  9 from g2
    STR
  end

  it "does not log a bad key" do
    proc { subject.foo }.must_raise Config::Configuration::UnknownKey
    log_string.must_be_empty
  end
end


