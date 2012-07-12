require 'helper'

describe "filesystem", Config::Core::Remotes do

  describe ".from_configuration" do

    let(:configuration) { Config::Configuration.new }

    it "loads nothing" do
      remotes = Config::Core::Remotes.from_configuration(configuration)
      remotes.project_git_config.must_equal nil
      remotes.database_git_config.must_equal nil
      remotes.standalone_ssh_configs.must_equal []
    end

    it "loads everything" do
      configuration.set_group(:project_git_config,
        url: "git@github.com:rcarver/config-example.git"
      )
      configuration.set_group(:database_git_config,
        url: "git@github.com:rcarver/config-example-db.git"
      )
      configuration.set_group(:ssh_configs,
        # TODO: reconsider how this data is structured.
        # The current thinking is to let a group have multiple items.
        github: {
          host: "git-tastic",
          hostname: "github.com",
          user: "git",
          port: 99,
          ssh_key: "github"
        },
        example: {
          host: "example.com",
          ssh_key: "example"
        }
      )
      remotes = Config::Core::Remotes.from_configuration(configuration)

      remotes.project_git_config.url.must_equal "git@github.com:rcarver/config-example.git"

      remotes.database_git_config.url.must_equal "git@github.com:rcarver/config-example-db.git"

      remotes.standalone_ssh_configs[0].host.must_equal "example.com"
      remotes.standalone_ssh_configs[0].ssh_key.must_equal "example"

      remotes.standalone_ssh_configs[1].host.must_equal "git-tastic"
      remotes.standalone_ssh_configs[1].hostname.must_equal "github.com"
      remotes.standalone_ssh_configs[1].user.must_equal "git"
      remotes.standalone_ssh_configs[1].port.must_equal 99
      remotes.standalone_ssh_configs[1].ssh_key.must_equal "github"
    end
  end
  describe ".default" do

    # It would be cool if Pathname implemented #chdir.
    # But it doesn't. So we do this.
    let(:chdir) do
      Class.new do
        def initialize(dir)
          @dir = dir
        end
        def chdir(&block)
          ::Dir.chdir(@dir, &block) if @dir.exist?
        end
      end
    end

    let(:project_dir)  { tmpdir + "project" }
    let(:database_dir) { tmpdir + "database" }

    let(:remotes) do
      Config::Core::Remotes.default(chdir.new(project_dir), chdir.new(database_dir))
    end

    specify "when nothing is in git" do
      remotes.project_git_config.url.must_equal  nil
      remotes.database_git_config.url.must_equal nil
    end

    specify "when the project is in git but the database is not" do
      (project_dir + ".git").mkpath
      (project_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      remotes.project_git_config.url.must_equal  'git@github.com:foo/bar.git'
      remotes.database_git_config.url.must_equal 'git@github.com:foo/bar-db.git'
    end

    specify "when the project is in git and the database is in git" do
      (project_dir + ".git").mkpath
      (project_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      (database_dir + ".git").mkpath
      (database_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar-database.git'
      end
      remotes.project_git_config.url.must_equal  'git@github.com:foo/bar.git'
      remotes.database_git_config.url.must_equal 'git@github.com:foo/bar-database.git'
    end
  end
end
