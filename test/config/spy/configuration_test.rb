require 'helper'

describe Config::Spy::Configuration do

  let(:levels) { [] }

  before do
    level = Levels::Level.new("one")
    level.set_group(:sample, a: 1)
    levels << level
  end

  subject { Config::Spy::Configuration.spy_and_merge("spy level", *levels) }

  specify "#to_s" do
    subject.to_s.must_equal "<Levels::Configuration spy level, one>"
  end

  it "accumulates the groups and values have been accessed" do
    subject.get_accessed_groups.must_equal({})
    subject[:foo].a
    subject.foo.a
    subject.foo.b
    subject.bar.a
    subject.get_accessed_groups.must_equal(
      foo: [:a, :b],
      bar: [:a]
    )
  end

  it "does not accumulate the keys that have been inquired about" do
    subject.foo?
    subject.foo.a?
    subject.get_accessed_groups.must_equal({})
  end

  it "provides a fake value for any undefined value" do
    subject.sample.a.must_equal 1
    subject.sample.b.must_equal "spy:sample.b"
    subject.other.a.must_equal "spy:other.a"
  end
end

