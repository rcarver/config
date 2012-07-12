require 'helper'

describe Config::Project do

  let(:project_loader) { MiniTest::Mock.new }
  let(:data)   { MiniTest::Mock.new }
  let(:nodes)  { MiniTest::Mock.new }

  subject { Config::Project.new(project_loader, data, nodes) }

  after do
    project_loader.verify
    data.verify
    nodes.verify
  end

  describe "executing blueprints" do

    let(:blueprint) { MiniTest::Mock.new }
    let(:cluster) { MiniTest::Mock.new }
    let(:config_self) { MiniTest::Mock.new }

    let(:facts) { MiniTest::Mock.new }

    let(:pattern) { MiniTest::Mock.new }
    let(:accumulation) { [pattern] }

    let(:configuration) { Config::Configuration.new }

    after do
      blueprint.verify
      cluster.verify
      config_self.verify
      facts.verify
      pattern.verify
    end

    before do
      # Load assets
      project_loader.expect(:require_all, nil)
      project_loader.expect(:get_blueprint, blueprint, ["webserver"])

      # Self configuration
      project_loader.expect(:get_self, config_self)
      config_self.expect(:configuration, configuration)

      # Configure the blueprint.
      blueprint.expect(:configuration=, nil, [assigned_configuration_class])
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

        let(:assigned_configuration_class) { Config::Configuration }

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

        let(:assigned_configuration_class) { Config::Spy::Configuration }

        it "executes the blueprint in noop mode, with a spy cluster" do
          result = subject.try_blueprint("webserver")
          result.must_equal accumulation
        end
      end
    end

    describe "#execute_node" do

      let(:node) { Config::Node.new("production", "webserver", "1") }

      let(:assigned_configuration_class) { Config::Configuration }

      before do
        node.facts = facts
        nodes.expect(:find_node, node, [node.fqn])

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

  describe "retrieving configuration" do

    let(:cluster) { MiniTest::Mock.new }
    let(:config_self) { MiniTest::Mock.new }

    let(:configuration) { Config::Configuration.new }

    before do
      cluster.expect(:configuration, configuration)
      config_self.expect(:configuration, configuration)

      project_loader.expect(:get_self, config_self)
      project_loader.expect(:get_cluster, cluster, ["production"])
    end

    after do
      cluster.verify
      config_self.verify
    end

    describe "#remotes_for" do

      it "builds remotes from the config" do
        subject.remotes_for("production").must_be_instance_of Config::Core::Remotes
      end
    end

    describe "#domain_for" do

      it "returns the configured domain" do
        configuration.set_group(:project_hostname, domain: "example.com")
        subject.domain_for("production").must_equal "example.com"
      end
    end
  end
end
