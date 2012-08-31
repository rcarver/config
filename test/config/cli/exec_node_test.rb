require 'helper'

describe Config::CLI::ExecNode do

  subject { Config::CLI::ExecNode }

  specify "#usage" do
    cli.usage.must_equal "test-command <fqn>"
  end

  describe "#parse" do
    it "gets the fqn from the args" do
      cli.parse! %w(a-b-c)
      cli.fqn.must_equal "a-b-c"
    end
    it "fails if no args are given" do
      expect_fail_with_usage { cli.parse! }
    end
  end

  describe "#execute" do

    let(:settings) { MiniTest::Mock.new }

    before do
      cli.fqn = "a-b-c"

      settings.expect(:fact_finder, -> { "facts" })

      nodes.expect(:update_node, nil, ["a-b-c", "facts"])

      project_loader.expect(:require_all, nil)
      private_data.expect(:accumulation, :acc1)
      project.expect(:execute_node, :acc2, ["a-b-c", :acc1])
      private_data.expect(:accumulation=, nil, [:acc2])

      directories.expect(:create_run_dir!, nil)
      directories.expect(:run_dir, "/tmp")
    end

    describe "when the node does not exist" do

      before do
        project.expect(:node?, false, ["a-b-c"])
        project.expect(:base_settings, settings)
      end

      it "updates and executes the node" do
        cli.execute
      end
    end

    describe "when the node exists" do

      before do
        project.expect(:node?, true, ["a-b-c"])
        project.expect(:node_settings, settings, ["a-b-c"])
      end

      it "updates and executes the node" do
        cli.execute
      end
    end
  end
end

