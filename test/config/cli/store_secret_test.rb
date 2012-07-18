require 'helper'

describe Config::CLI::StoreSecret do

  subject { Config::CLI::StoreSecret }

  specify "#usage" do
    cli.usage.must_equal "test-command [<name>]"
  end

  describe "#parse" do

    let(:input_stream) { "data" }

    it "gets the name from the args" do
      cli.parse! %w(foo)
      cli.secret_name.must_equal "foo"
    end
    it "has a default name" do
      cli.parse!
      cli.secret_name.must_equal "default"
    end
    it "gets data from stdin" do
      cli.parse!
      cli.data.must_equal "data"
    end
  end

  describe "#execute" do
    it "stores the secret" do
      cli.secret_name = "mine"
      cli.data = "xyz"
      private_data.expect(:secret, expect_write_file("xyz"), ["mine"])
      cli.execute
    end
  end
end



