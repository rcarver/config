require 'helper'

describe Config::CLI::CreateBootstrap do

  subject { Config::CLI::CreateBootstrap }

  specify "#usage" do
    cli.usage.must_equal "test-command <cluster> <blueprint> <identity>"
  end

  describe "#parse" do
    it "gets the parts from args" do
      cli.parse! %w(production webserver 1)
      cli.cluster_name.must_equal "production"
      cli.blueprint_name.must_equal "webserver"
      cli.identity.must_equal "1"
      cli.log.must_equal false
    end
    it "fails if no identity is given" do
      expect_fail_with_usage { cli.parse! %w(production webserver) }
    end
    it "fails if no blueprint is given" do
      expect_fail_with_usage { cli.parse! %w(production) }
    end
    it "fails if nothing is given" do
      expect_fail_with_usage { cli.parse! }
    end
    specify "--log" do
      cli.parse! %w(production webserver 1 --log)
      cli.log.must_equal true
    end
  end

  describe "#execute" do
    it "executes a blueprint" do
      skip "This is too hard to stub. Need to test against real objects"

      project.expect(:require_all, nil)
      project.expect(:get_cluster, nil, ["production"])
      project.expect(:get_blueprint, nil, ["webserver"])

      cli.cluster_name = "production"
      cli.blueprint_name = "webserver"
      cli.identity = "1"
      cli.execute

      system = cli.find_blueprints(Config::Bootstrap::System)
      system.size.must_equal 1

      identity = cli.find_blueprints(Config::Bootstrap::Identity)
      identity.size.must_equal 1

      access = cli.find_blueprints(Config::Bootstrap::Access)
      access.size.must_equal 1

      project = cli.find_blueprints(Config::Bootstrap::Project)
      project.size.must_equal 1

      stdout.string.must_match /ok/
    end
  end
end




