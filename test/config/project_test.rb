require 'helper'

describe Config::Project do

  let(:project_loader) { MiniTest::Mock.new }
  let(:nodes)  { MiniTest::Mock.new }

  subject { Config::Project.new(project_loader, nodes) }

  after do
    project_loader.verify
    nodes.verify
  end

  describe "executing blueprints" do

    let(:blueprint) { MiniTest::Mock.new }
    let(:cluster) { MiniTest::Mock.new }
    let(:global) { MiniTest::Mock.new }

    let(:facts) { MiniTest::Mock.new }

    let(:pattern) { MiniTest::Mock.new }
    let(:accumulation) { [pattern] }

    let(:configuration) { Config::Configuration.new }

    after do
      blueprint.verify
      cluster.verify
      global.verify
      facts.verify
      pattern.verify
    end

    before do
      # Load assets
      project_loader.expect(:require_all, nil)
      project_loader.expect(:get_blueprint, blueprint, ["webserver"])

      # Global configuration
      project_loader.expect(:get_global, global)
      global.expect(:configuration, configuration)

      # Configure the blueprint.
      blueprint.expect(:configuration=, nil, [assigned_configuration_class])
      blueprint.expect(:cluster_context=, nil, [assigned_cluster_context_class])
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

        let(:assigned_configuration_class) { Levels::Configuration }
        let(:assigned_cluster_context_class) { Config::ClusterContext }

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

        let(:assigned_configuration_class) { Config::Spy::Configuration::SpyMerged }
        let(:assigned_cluster_context_class) { Config::Spy::ClusterContext }

        it "executes the blueprint in noop mode, with a spy cluster" do
          result = subject.try_blueprint("webserver")
          result.must_equal accumulation
        end
      end
    end

    describe "#execute_node" do

      let(:node) { Config::Node.new("production", "webserver", "1") }

      let(:assigned_configuration_class) { Levels::Configuration }
      let(:assigned_cluster_context_class) { Config::ClusterContext }

      before do
        node.facts = facts
        nodes.expect(:get_node, node, [node.fqn])

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

  describe "project settings" do

    let(:global) { MiniTest::Mock.new }
    let(:configuration) { Config::Configuration.new }

    before do
      global.expect(:configuration, configuration)
      project_loader.expect(:get_global, global)
    end

    after do
      global.verify
    end

    describe "#base_settings" do

      it "includes the self configuration" do
        subject.base_settings.must_be_instance_of Config::ProjectSettings
      end
    end

    describe "#node_settings" do

      let(:node) { MiniTest::Mock.new }
      let(:cluster) { MiniTest::Mock.new }

      it "includes the self, cluster and node configurations" do
        nodes.expect(:get_node, node, ["production-webserver-1"])
        # TODO: load node configuration
        #node.expect(:configuration, configuration)
        node.expect(:cluster_name, "production")

        cluster.expect(:configuration, configuration)
        project_loader.expect(:get_cluster, cluster, ["production"])

        subject.node_settings("production-webserver-1").must_be_instance_of Config::ProjectSettings

        cluster.verify
        node.verify
      end
    end

    describe "#cluster_settings" do

      let(:cluster) { MiniTest::Mock.new }

      it "includes the self and cluster configurations" do
        cluster.expect(:configuration, configuration)
        project_loader.expect(:get_cluster, cluster, ["production"])

        subject.cluster_settings("production").must_be_instance_of Config::ProjectSettings

        cluster.verify
      end
    end
  end
end
