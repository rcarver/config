require 'helper'

describe Config::CLI::UpdateDatabase do

  subject { Config::CLI::UpdateDatabase }

  specify "#usage" do
    cli.usage.must_equal "test-command [<fqn>]"
  end

  describe "#parse" do
    it "gets the fqn from args" do
      cli.parse! %w(production-webserver-1)
      cli.fqn.must_equal "production-webserver-1"
    end
    it "has no fqn no args are given" do
      cli.parse! %w()
      cli.fqn.must_equal nil
    end
  end

  describe "#execute" do

    let(:remotes) { MiniTest::Mock.new }
    let(:settings) { MiniTest::Mock.new }

    before do
      database.expect(:path, "repo-path")
      database.expect(:update, nil)
      project_data.expect(:database, database)

      database_git_config = MiniTest::Mock.new
      database_git_config.expect(:url, "repo-url")

      remotes.expect(:database_git_config, database_git_config)

      settings.expect(:remotes, remotes)
    end

    describe "with an fqn" do

      it "executes a blueprint" do
        cli.fqn = "production-webserver-1"

        project.expect(:node_settings, settings, ["production-webserver-1"])

        cli.execute

        clones = cli.find_blueprints(Config::Meta::CloneDatabase)
        clones.size.must_equal 1
        clones[0].path.must_equal "repo-path"
        clones[0].url.must_equal "repo-url"
      end
    end

    describe "without an fqn" do

      it "executes a blueprint" do
        cli.fqn = nil

        project.expect(:base_settings, settings)

        cli.execute

        clones = cli.find_blueprints(Config::Meta::CloneDatabase)
        clones.size.must_equal 1
        clones[0].path.must_equal "repo-path"
        clones[0].url.must_equal "repo-url"
      end
    end
  end
end




