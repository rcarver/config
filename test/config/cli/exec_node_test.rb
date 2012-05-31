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
    it "updates and executes the node" do
      cli.fqn = "a-b-c"
      project.expect(:require_all, nil)
      project.expect(:update_node, nil, ["a-b-c"])
      data_dir.expect(:accumulation, :acc1)
      project.expect(:execute_node, :acc2, ["a-b-c", :acc1])
      data_dir.expect(:accumulation=, nil, [:acc2])
      cli.execute
    end
  end
end

