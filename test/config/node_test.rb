require 'helper'

describe Config::Node do

  let(:cluster) { MiniTest::Mock.new }
  let(:blueprint) { MiniTest::Mock.new }

  subject { Config::Node.new(cluster, blueprint) }

  describe "execute" do

    before do
      blueprint.expect(:node=, nil, [subject])
      blueprint.expect(:cluster=, nil, [cluster])
    end

    after do
      cluster.verify
      blueprint.verify
    end

    specify "normal" do
      blueprint.expect(:execute, nil, [nil])
      subject.execute
    end

    specify "with previous accumulation" do
      subject.previous_accumulation = :accumulation
      blueprint.expect(:execute, nil, [:accumulation])
      subject.execute
    end
  end
end
