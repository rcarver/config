require 'helper'

describe Config::ProjectSettings do

  let(:configuration) { Config::Configuration.new }
  let(:private_data)  { Config::PrivateData.new }

  subject { Config::ProjectSettings.new(configuration, private_data) }

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
      remotes.project_git_config.url.must_equal nil
      remotes.database_git_config.url.must_equal nil
      remotes.standalone_ssh_configs.must_equal []
    end

    it "loads everything" do
      configuration.set_group(:project_git_config,
        url: "git@github.com:rcarver/config-example.git"
      )
      configuration.set_group(:database_git_config,
        url: "git@github.com:rcarver/config-example-db.git"
      )
      #configuration.set_group(:ssh_configs,
        #{
          #host: "git-tastic",
          #hostname: "github.com",
          #user: "git",
          #port: 99,
          #ssh_key: "github"
        #},
        #{
          #host: "example.com",
          #ssh_key: "example"
        #}
      #)

      remotes = subject.remotes

      remotes.project_git_config.url.must_equal "git@github.com:rcarver/config-example.git"
      remotes.project_git_config.host.must_equal "github.com"
      remotes.project_git_config.hostname.must_equal "github.com"
      remotes.project_git_config.user.must_equal "git"
      remotes.project_git_config.port.must_equal 22
      remotes.project_git_config.ssh_key.must_equal "default"

      remotes.database_git_config.url.must_equal "git@github.com:rcarver/config-example-db.git"
      remotes.database_git_config.host.must_equal "github.com"
      remotes.database_git_config.hostname.must_equal "github.com"
      remotes.database_git_config.user.must_equal "git"
      remotes.database_git_config.port.must_equal 22
      remotes.database_git_config.ssh_key.must_equal "default"

      # TODO: figure out ssh_configs syntax (current thought is to make a Configuration::RepeatedSet)
      remotes.standalone_ssh_configs.must_be_empty

      #remotes.standalone_ssh_configs[0].host.must_equal "git-tastic"
      #remotes.standalone_ssh_configs[0].hostname.must_equal "github.com"
      #remotes.standalone_ssh_configs[0].user.must_equal "git"
      #remotes.standalone_ssh_configs[0].port.must_equal 99
      #remotes.standalone_ssh_configs[0].ssh_key.must_equal "github"

      #remotes.standalone_ssh_configs[1].host.must_equal "example.com"
      #remotes.standalone_ssh_configs[1].ssh_key.must_equal "example"
    end
  end

  describe "#cipher" do

    it "configures a cipher based on the current partition" do
      skip
    end
  end
end
