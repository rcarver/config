require 'helper'

describe Config::CLI::UpdateDatabase do

  subject { Config::CLI::UpdateDatabase }

  specify "#usage" do
    cli.usage.must_equal "test-command"
  end

  describe "#execute" do
    it "executes a blueprint" do

      database.expect(:path, "repo-path")
      database.expect(:update, nil)
      project_data.expect(:database, database)

      database_git_config = MiniTest::Mock.new
      database_git_config.expect(:url, "repo-url")

      remotes = MiniTest::Mock.new
      remotes.expect(:database_git_config, database_git_config)
      project_data.expect(:remotes, remotes)

      cli.execute

      clones = cli.find_blueprints(Config::Meta::CloneDatabase)
      clones.size.must_equal 1
      clones[0].path.must_equal "repo-path"
      clones[0].url.must_equal "repo-url"

      database.verify
    end
  end
end




