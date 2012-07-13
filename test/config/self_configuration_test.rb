require 'helper'

describe Config::SelfConfiguration do

  let(:configuration) { Config::Configuration.new }

  subject { Config::SelfConfiguration.new(configuration) }

  describe "#domain" do

    it "returns nil" do
      subject.domain.must_equal nil
    end

    it "returns a value" do
      configuration.set_group(:project_hostname, domain: "example.com")
      subject.domain.must_equal "example.com"
    end
  end

  describe "#remotes" do

    it "loads nothing" do
      remotes = subject.remotes
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
        {
          host: "git-tastic",
          hostname: "github.com",
          user: "git",
          port: 99,
          ssh_key: "github"
        },
        {
          host: "example.com",
          ssh_key: "example"
        }
      )
      remotes = subject.remotes

      remotes.project_git_config.url.must_equal "git@github.com:rcarver/config-example.git"

      remotes.database_git_config.url.must_equal "git@github.com:rcarver/config-example-db.git"

      remotes.standalone_ssh_configs[0].host.must_equal "git-tastic"
      remotes.standalone_ssh_configs[0].hostname.must_equal "github.com"
      remotes.standalone_ssh_configs[0].user.must_equal "git"
      remotes.standalone_ssh_configs[0].port.must_equal 99
      remotes.standalone_ssh_configs[0].ssh_key.must_equal "github"

      remotes.standalone_ssh_configs[1].host.must_equal "example.com"
      remotes.standalone_ssh_configs[1].ssh_key.must_equal "example"
    end
  end
end
