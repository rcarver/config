require 'helper'

describe Config::Core::Executor do

  let(:accumulation) { MiniTest::Mock.new }
  let(:patterns)    { [] }

  before do
    accumulation.expect(:patterns, patterns)
  end

  subject { Config::Core::Executor.new(accumulation) }

  describe "#accumulate" do
    it "recursively calls patterns until all are found" do
      called = []

      a = lambda { called << "a" }
      b = lambda { called << "b"; patterns << a }
      c = lambda { called << "c" }
      d = lambda { called << "d"; patterns << c; patterns << b }
      e = lambda { called << "e" }
      f = lambda { called << "f"; patterns << d }

      patterns.concat [e, f]

      subject.accumulate

      called.must_equal %w(e f d c b a)
      patterns.must_equal [e, f, d, c, b, a]
    end
  end

  describe "#execute" do
    it "tells each pattern to execute" do
      a = MiniTest::Mock.new
      b = MiniTest::Mock.new

      patterns.concat [a, b]

      a.expect(:execute, nil)
      b.expect(:execute, nil)

      subject.execute

      a.verify
      b.verify
    end
  end
end

