require 'helper'

describe Config::CLI::CreateCluster do

  subject { Config::CLI::CreateCluster }

  specify "#usage" do
    cli.usage.must_equal "test-command <name>..."
  end

  describe "#parse" do
    it "gets the names from name args" do
      cli.parse! %w(abc def)
      cli.cluster_names.must_equal ["abc", "def"]
    end
    it "fails if no name is given" do
      expect_fail_with_usage { cli.parse! }
    end
  end

  describe "#execute" do
    it "executes a blueprint" do
      cli.cluster_names = ["a", "b"]
      cli.execute
      blueprints = cli.find_blueprints(Config::Meta::Cluster)
      blueprints.size.must_equal 2
      blueprints[0].name.must_equal "a"
      blueprints[1].name.must_equal "b"
    end
  end
end


