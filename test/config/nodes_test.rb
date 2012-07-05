require 'helper'

describe Config::Nodes do

  let(:node) { Config::Node.new("production", "message", "one") }
  let(:facts) { Config::Core::Facts.new("ec2" => { "ip_address" => "127.0.0.1" }) }
  let(:database) { MiniTest::Mock.new }

  subject { Config::Nodes.new(database) }

  after do
    database.verify
  end

  describe "#find_node" do

    it "looks in the database" do
      database.expect(:find_node, node, [node.fqn])
      subject.find_node(node.fqn).must_equal node
    end

    it "returns nil if the node does not exist" do
      database.expect(:find_node, nil, [node.fqn])
      subject.find_node(node.fqn).must_equal nil
    end
  end

  describe "#update_node" do

    let(:fact_finder) { -> { facts } }

    it "updates the node's facts and stores it in the database" do
      database.expect(:find_node, node, [node.fqn])
      database.expect(:update_node, nil, [node])
      subject.update_node(node.fqn, fact_finder)
      node.facts.must_equal facts
    end

    it "creates a new node if none exists" do
      database.expect(:find_node, nil, [node.fqn])
      database.expect(:update_node, nil, [node])
      updated_node = subject.update_node(node.fqn, fact_finder)
      updated_node.facts.must_equal facts
    end
  end

  describe "#remove_node" do

    it "removes the node from the database" do
      database.expect(:find_node, node, [node.fqn])
      database.expect(:remove_node, nil, [node])
      subject.remove_node(node.fqn)
    end

    it "does nothing if the node does not exist" do
      database.expect(:find_node, nil, [node.fqn])
      subject.remove_node(node.fqn)
    end
  end
end
