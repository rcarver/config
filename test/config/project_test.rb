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

    let(:configuration) { MiniTest::Mock.new }
    let(:facts) { MiniTest::Mock.new }

    let(:pattern) { MiniTest::Mock.new }
    let(:accumulation) { [pattern] }

    after do
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
end
