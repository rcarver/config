require 'helper'

describe Config::Core::Executor do

  let(:accumulation) { [] }

  subject { Config::Core::Executor.new(accumulation) }

  describe "#accumulate" do
    it "recursively calls patterns until all are found" do
      called = []

      a = lambda { called << "a" }
      b = lambda { called << "b"; accumulation << a }
      c = lambda { called << "c" }
      d = lambda { called << "d"; accumulation << c; accumulation << b }
      e = lambda { called << "e" }
      f = lambda { called << "f"; accumulation << d }
      g = lambda { called << "g"; accumulation << e }

      accumulation.concat [f, g]

      subject.accumulate

      called.must_equal %w(f g d e c b a)
      accumulation.must_equal [f, g, d, e, c, b, a]
    end
  end

  describe "#execute" do
    it "tells each pattern to execute" do
      a = MiniTest::Mock.new
      b = MiniTest::Mock.new

      accumulation.concat [a, b]

      a.expect(:execute, nil)
      b.expect(:execute, nil)

      subject.execute

      a.verify
      b.verify
    end
  end
end

