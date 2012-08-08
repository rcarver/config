require 'helper'

describe Config::Configuration::Merged do

  let(:level1) { Config::Configuration::Level.new("l1") }
  let(:level2) { Config::Configuration::Level.new("l2") }

  subject { Config::Configuration::Merged.new([level1, level2]) }

  before do
    level1.set_group(:g1, a: 1)

    level2.set_group(:g1, a: 9)
    level2.set_group(:g2, b: 2)
  end

  specify "#to_s" do
    subject.to_s.must_equal "<Configuration::Merged l1, l2>"
  end

  it "allows groups to be retrieved" do
    subject.g1.must_be_instance_of Config::Configuration::MergedGroup
    subject[:g1].must_be_instance_of Config::Configuration::MergedGroup
  end

  it "initializes the merged group with the right levels" do
    subject.g1.a.must_equal 9
    subject.g1.b?.must_equal false

    subject.g2.b.must_equal 2
    subject.g2.a?.must_equal false
  end

  it "raises an error if you access an unknown group" do
    proc { subject.nothing }.must_raise Config::Configuration::UnknownGroup
    proc { subject[:nothing] }.must_raise Config::Configuration::UnknownGroup
  end

  it "allows the existence of a group to be tested" do
    subject.defined?(:g1).must_equal true
    subject.defined?(:g2).must_equal true
    subject.defined?(:foo).must_equal false
    subject.g1?.must_equal true
    subject.g2?.must_equal true
    subject.foo?.must_equal false
  end
end

