require 'helper'

describe Config::CLI::TryBlueprint do

  subject { Config::CLI::TryBlueprint }

  specify "#usage" do
    cli.usage.must_equal "test-command <blueprint> [<cluster>]"
  end

  describe "#parse" do
    it "gets a blueprint and a cluster from args" do
      cli.parse! %w(webserver production)
      cli.blueprint_name.must_equal "webserver"
      cli.cluster_name.must_equal "production"
    end
    it "does not require a cluster" do
      cli.parse! %w(webserver)
      cli.blueprint_name.must_equal "webserver"
      cli.cluster_name.must_equal nil
    end
    it "fails without a blueprint" do
      expect_fail_with_usage { cli.parse! }
    end
  end

  describe "#execute" do
    it "executes a blueprint and cluster" do
      cli.blueprint_name = "webserver"
      cli.cluster_name = "production"
      project.expect(:try_blueprint, nil, ["webserver", "production"])
      cli.execute
    end
    it "executes a blueprint without cluster" do
      cli.blueprint_name = "webserver"
      cli.cluster_name = nil
      project.expect(:try_blueprint, nil, ["webserver", nil])
      cli.execute
    end
  end
end



