require 'helper'

describe "filesystem", Config::Core::RemotesSerializer do

  let(:yaml) do
    <<-STR
      project_git_config:
        url: git@github.com:rcarver/config-example.git
      database_git_config:
        url: git@github.com:rcarver/config-example-db.git
      ssh_configs:
        - host: example.com
          user: bar
    STR
  end

  let(:data) { YAML.load(yaml) }

  subject { Config::Core::RemotesSerializer }

  describe ".load" do

    it "works with data" do
      remotes = subject.load(data)
      remotes.project_git_config.url.must_equal "git@github.com:rcarver/config-example.git"
      remotes.database_git_config.url.must_equal "git@github.com:rcarver/config-example-db.git"
      remotes.standalone_ssh_configs.size.must_equal 1
      remotes.standalone_ssh_configs.last.user.must_equal "bar"
    end

    it "works when empty" do
      remotes = subject.load({})
      remotes.project_git_config.must_equal nil
      remotes.database_git_config.must_equal nil
      remotes.standalone_ssh_configs.must_equal []
    end

    it "works with bad data" do
      remotes = subject.load(nil)
      remotes.must_be_instance_of Config::Core::Remotes
    end
  end

  describe ".dump" do

    it "works with data" do
      remotes = subject.load(data)
      data = subject.dump(remotes)
      data["project_git_config"]["url"].must_equal "git@github.com:rcarver/config-example.git"
      data["database_git_config"]["url"].must_equal "git@github.com:rcarver/config-example-db.git"
      data["ssh_configs"].size.must_equal 1
      data["ssh_configs"][0]["user"].must_equal "bar"
    end

    it "works when empty" do
      remotes = subject.load({})
      data = subject.dump(remotes)
      data["project_git_config"].must_equal({})
      data["database_git_config"].must_equal({})
      data["ssh_configs"].must_equal []
    end
  end
end

