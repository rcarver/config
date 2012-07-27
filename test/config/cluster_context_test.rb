require 'helper'

describe Config::ClusterContext do

  let(:cluster) { MiniTest::Mock.new }
  let(:nodes)   { MiniTest::Mock.new }

  subject { Config::ClusterContext.new(cluster, nodes) }

  before do
    cluster.expect(:name, "prod")
  end

  it "exposes the cluster name" do
    subject.name.must_equal "prod"
  end

  describe "node finders" do

    def make_node(fqn)
      Config::Node.from_fqn(fqn)
    end

    describe "#get_node" do

      it "returns a node by fqn" do
        node = make_node("prod-test-1")
        nodes.expect(:get_node, node, ["prod-test-1"])
        subject.get_node("prod-test-1").must_equal node
      end

      it "does not return a node not in this cluster" do
        node = make_node("stage-test-1")
        nodes.expect(:get_node, node, ["stage-test-1"])
        subject.get_node("stage-test-1").must_equal nil
      end
    end

    describe "#find_node" do

      it "returns a node in this cluster" do
        node = make_node("prod-test-1")
        nodes.expect(:find_node, node, ["search", "params"])
        subject.find_node("search", "params").must_equal node
      end

      it "does not return a node not in this cluster" do
        node = make_node("stage-test-1")
        nodes.expect(:find_node, node, ["search", "params"])
        subject.find_node("search", "params").must_equal nil
      end
    end

    describe "#find_all_nodes" do

      it "only returns nodes in this cluster" do
        prod = make_node("prod-test-1")
        stage = make_node("stage-test-1")
        nodes.expect(:find_all_nodes, [prod, stage], ["search", "params"])
        subject.find_all_nodes("search", "params").must_equal [prod]
      end
    end
  end
end
