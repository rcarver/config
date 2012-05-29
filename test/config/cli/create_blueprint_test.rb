require 'helper'
require 'ostruct'

describe Config::CLI::CreateBlueprint do

  subject { Config::CLI::CreateBlueprint }

  specify "#usage" do
    cli.usage.must_equal "test-command [HOST]"
  end

  describe "#parse" do
    it "gets hosts from the name args" do
      cli.parse! ["a", "b", "c"]
      cli.hosts.must_equal ["a", "b", "c"]
    end
    it "defaults to hosts from the project" do
      project.expect(:ssh_hosts, ["a", "b"])
      cli.parse!
      cli.hosts.must_equal ["a", "b"]
    end
  end

  describe "#execute" do
    it "gets the ssh signature for each host" do
      cli.hosts = ["a"]
      expect_system_call("xyz", "", 0, "ssh-keyscan -H a")
      data_dir.expect(:ssh_host_signature, expect_write_file("xyz"), ["a"])
      cli.execute
    end
  end
end
