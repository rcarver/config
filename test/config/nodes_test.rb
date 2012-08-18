require 'helper'

describe Config::Nodes do

  let(:node) { Config::Node.new("production", "message", "one") }
  let(:facts) { Config::Facts.new("ec2" => { "ip_address" => "127.0.0.1" }) }
  let(:database) { MiniTest::Mock.new }

  subject { Config::Nodes.new(database) }

  after do
    database.verify
  end

  describe "#get_node" do

    it "looks in the database" do
      database.expect(:all_nodes, [node])
      subject.get_node(node.fqn).must_equal node
    end

    it "returns nil if the node does not exist" do
      database.expect(:all_nodes, [node])
      subject.get_node("production-other-one").must_equal nil
    end
  end

  describe "#find_node" do

    it "returns a matching node" do
      skip
    end

    it "returns nil if no nodes match" do
      skip
    end

    it "raises an exception if more than one node matches" do
      skip
    end
  end

  describe "#find_all_nodes" do

    it "returns matching nodes" do
      skip
    end
  end

  describe "#update_node" do

    let(:fact_finder) { -> { facts } }

    it "updates the node's facts and stores it in the database" do
      database.expect(:all_nodes, [node])
      database.expect(:update_node, nil, [node])
      subject.update_node(node.fqn, fact_finder)
      node.facts.must_equal facts
    end

    it "creates a new node if none exists" do
      database.expect(:all_nodes, [])
      database.expect(:update_node, nil, [node])
      updated_node = subject.update_node(node.fqn, fact_finder)
      updated_node.facts.must_equal facts
    end
  end

  describe "#remove_node" do

    it "removes the node from the database" do
      database.expect(:all_nodes, [node])
      database.expect(:remove_node, nil, [node])
      subject.remove_node(node.fqn)
    end

    it "does nothing if the node does not exist" do
      database.expect(:all_nodes, [])
      subject.remove_node(node.fqn)
    end
  end
end
