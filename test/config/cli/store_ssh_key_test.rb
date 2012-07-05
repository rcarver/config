require 'helper'

describe Config::CLI::StoreSSHKey do

  subject { Config::CLI::StoreSSHKey }

  specify "#usage" do
    cli.usage.must_equal "test-command [<name>]"
  end

  describe "#parse" do

    let(:input_stream) { "data" }

    it "gets the name from the args" do
      cli.parse! %w(foo)
      cli.ssh_key_name.must_equal "foo"
    end
    it "has a default name" do
      cli.parse!
      cli.ssh_key_name.must_equal "default"
    end
    it "gets data from stdin" do
      cli.parse!
      cli.data.must_equal "data"
    end
  end

  describe "#execute" do
    it "stores the key" do
      cli.ssh_key_name = "mine"
      cli.data = "xyz"
      project_data.expect(:ssh_key, expect_write_file("xyz"), ["mine"])
      cli.execute
    end
  end
end




