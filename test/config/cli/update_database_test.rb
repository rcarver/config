require 'helper'

describe Config::CLI::UpdateDatabase do

  subject { Config::CLI::UpdateDatabase }

  specify "#usage" do
    cli.usage.must_equal "test-command"
  end

  describe "#execute" do
    it "executes a blueprint" do
      project.expect(:update_database, nil)

      data_dir = MiniTest::Mock.new
      data_dir.expect(:repo_path, "repo-path")

      hub = MiniTest::Mock.new
      data_config = MiniTest::Mock.new
      hub.expect(:data_config, data_config)
      data_config.expect(:url, "hub-url")

      project.expect(:data_dir, data_dir)
      project.expect(:hub, hub)

      cli.execute

      clones = cli.find_blueprints(Config::Meta::CloneDatabase)
      clones.size.must_equal 1
      clones[0].path.must_equal "repo-path"
      clones[0].url.must_equal "hub-url"
    end
  end
end




