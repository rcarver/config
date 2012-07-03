require 'helper'

describe Config::Project do

  subject { Config::Project.new("/tmp/project", "/tmp/data") }

  describe "loader operations" do

    let(:loader) { MiniTest::Mock.new }

    before do
      subject.loader = loader
    end

    after do
      loader.verify
    end

    describe "#require_all" do

      it "delegates to the loader" do
        loader.expect(:require_all, nil)
        subject.require_all
      end
    end

    describe "#ssh_hostnames" do

      it "delegates to the hub" do
        hub = MiniTest::Mock.new
        loader.expect(:get_hub, hub)
        hub.expect(:ssh_hostnames, ["a", "b"])
        subject.loader = loader
        subject.ssh_hostnames.must_equal ["a", "b"]
      end
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

  describe "executing blueprints" do

    let(:project_loader) { MiniTest::Mock.new }

    let(:blueprint) { MiniTest::Mock.new }
    let(:cluster) { MiniTest::Mock.new }

    let(:configuration) { MiniTest::Mock.new }
    let(:facts) { MiniTest::Mock.new }

    let(:pattern) { MiniTest::Mock.new }
    let(:accumulation) { [pattern] }

    before do
      subject.loader = project_loader
    end

    after do
      project_loader.verify
      blueprint.verify
      cluster.verify
      configuration.verify
      facts.verify
      pattern.verify
    end

    before do
      # Load assets
      project_loader.expect(:require_all, nil)
      project_loader.expect(:get_blueprint, blueprint, ["webserver"])

      # Configure the blueprint.
      blueprint.expect(:configuration=, nil, [configuration])
      blueprint.expect(:facts=, nil, [facts])

      # Execute the blueprint.
      blueprint.expect(:validate, nil)
      blueprint.expect(:execute, nil)
    end

    describe "#try_blueprint" do

      let(:facts) { Config::Spy::Facts.new }

      before do
        blueprint.expect(:noop!, accumulation)
      end

      describe "with a cluster" do

        before do
          project_loader.expect(:get_cluster, cluster, ["production"])
          cluster.expect(:configuration, configuration)
        end

        it "executes the blueprint in noop mode" do
          result = subject.try_blueprint("webserver", "production")
          result.must_equal accumulation
        end
      end

      describe "without a cluster" do

        let(:configuration) { Config::Spy::Configuration.new }

        it "executes the blueprint in noop mode, with a spy cluster" do
          result = subject.try_blueprint("webserver")
          result.must_equal accumulation
        end
      end
    end

    describe "#execute_node" do

      let(:node) { Config::Node.new("production", "webserver", "1") }
      let(:database) { MiniTest::Mock.new }

      before do
        node.facts = facts
        subject.database = database
      end

      after do
        database.verify
      end

      before do
        database.expect(:find_node, node, [node.fqn])

        project_loader.expect(:get_cluster, cluster, ["production"])
        cluster.expect(:configuration, configuration)
        blueprint.expect(:accumulate, accumulation)
      end

      it "executes the blueprint" do
        result = subject.execute_node(node.fqn)
        result.must_equal accumulation
      end

      it "executes the blueprint with a previous accumulation" do
        previous_accumulation = MiniTest::Mock.new
        blueprint.expect(:previous_accumulation=, nil, [previous_accumulation])

        result = subject.execute_node(node.fqn, previous_accumulation)
        result.must_equal accumulation
      end
    end
  end
end
