require 'helper'

describe Config::Core::Accumulation do

  subject { Config::Core::Accumulation.new }

  describe "#add" do

    let(:pattern_class) { MiniTest::Mock.new }
    let(:pattern) { MiniTest::Mock.new }
    let(:parent) { MiniTest::Mock.new }

    before do
      subject.current = parent
      pattern_class.expect(:new, pattern)
      pattern.expect(:accumulation=, nil, [subject])
      pattern.expect(:parent=, nil, [parent])
      pattern.expect(:log=, nil, [subject.log])
    end

    after do
      pattern_class.verify
      pattern.verify
    end

    it "instantiates the pattern" do
      subject.add(pattern_class)
    end

    it "instantiates the pattern with a block" do
      pattern.expect(:touch, nil)
      subject.add pattern_class do |p|
        p.touch
      end
    end

    it "stores the instantiated pattern" do
      subject.add(pattern_class)
      subject.to_a.must_equal [pattern]
    end
  end

end
