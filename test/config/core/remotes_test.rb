require 'helper'

describe Config::Core::Remotes do

  subject { Config::Core::Remotes.new }

  describe "by default" do

    it "has an empty project git config" do
      subject.project_git_config.must_be_instance_of Config::Core::GitConfig
      subject.project_git_config.url.must_equal nil
    end

    it "has an empty database git config" do
      subject.database_git_config.must_be_instance_of Config::Core::GitConfig
      subject.database_git_config.url.must_equal nil
    end

    it "has no standalone ssh configs" do
      subject.standalone_ssh_configs.must_equal []
    end

    it "has no ssh configs" do
      subject.ssh_configs.must_equal []
    end

    it "has no ssh hostnames" do
      subject.ssh_hostnames.must_equal []
    end
  end

  describe "with git configs" do

    before do
      subject.project_git_config.url = "git@github.com:rcarver/config-example.git"
      subject.database_git_config.url = "foo@foohub.com:rcarver/config-example.git"
    end

    it "has ssh configs" do
      subject.ssh_configs.size.must_equal 2
    end

    it "has ssh hostnames" do
      subject.ssh_hostnames.must_equal ["foohub.com", "github.com"]
    end
  end

  describe "with standalone ssh configs" do

    before do
      subject.standalone_ssh_configs << Config::Core::SSHConfig.new.tap { |c|
        c.host = "example.com"
        c.user = "ex"
      }
      subject.standalone_ssh_configs << Config::Core::SSHConfig.new.tap { |c|
        c.host = "foo.com"
        c.user = "foo"
      }
      subject.standalone_ssh_configs << Config::Core::SSHConfig.new.tap { |c|
        c.host = "foo-internal"
        c.hostname = "foo.com"
        c.user = "fooi"
      }
    end

    it "has ssh configs" do
      subject.ssh_configs.size.must_equal 3
    end

    it "has ssh hostnames" do
      subject.ssh_hostnames.must_equal ["example.com", "foo.com"]
    end
  end
end
