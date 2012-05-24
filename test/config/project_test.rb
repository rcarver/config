require 'helper'

describe Config::Project do

  subject { Config::Project.new("/tmp/project", "/tmp/data") }

  describe "#update" do

    let(:git_repo) { MiniTest::Mock.new }

    before do
      subject.git_repo = git_repo
    end

    after do
      git_repo.verify
    end

    it "returns :dirty if the repo isn't clean" do
      git_repo.expect(:clean_status?, false)

      subject.update.must_equal :dirty
    end

    it "returns :updated and updates the repo" do
      git_repo.expect(:clean_status?, true)
      git_repo.expect(:pull_rebase, nil)

      subject.update.must_equal :updated
    end
  end

  describe "node operations" do

    let(:node) { Config::Node.new("production", "message", "one") }
    let(:facts) { Config::Core::Facts.new("ec2" => { "ip_address" => "127.0.0.1" }) }
    let(:database) { MiniTest::Mock.new }

    before do
      subject.database = database
    end

    after do
      database.verify
    end

    describe "#update_node" do

      before do
        subject.fact_inventor = -> { facts }
      end

      it "updates the node's facts and stores it in the database" do
        database.expect(:find_node, node, [node.fqn])
        database.expect(:update_node, nil, [node])
        subject.update_node(node.fqn)
        node.facts.must_equal facts
      end

      it "creates a new node if none exists" do
        database.expect(:find_node, nil, [node.fqn])
        database.expect(:update_node, nil, [node])
        updated_node = subject.update_node(node.fqn)
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
end
