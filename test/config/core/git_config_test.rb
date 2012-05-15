require 'helper'

describe Config::Core::GitConfig do

  subject { Config::Core::GitConfig.new }

  it "defaults the ssh_key" do
    subject.ssh_key.must_equal "default"
    subject.ssh_key = "other"
    subject.ssh_key.must_equal "other"
  end

  it "creates an ssh config based on the url" do
    subject.url = "git@github.com:rcarver/config-example.rig"
    subject.ssh_key = "foo"

    config = subject.ssh_config
    config.host.must_equal "github.com"
    config.user.must_equal "git"
    config.ssh_key.must_equal "foo"
  end

  it "parses a url for the user and host" do
    subject.url = "git@github.com:rcarver/config-example.rig"
    subject.host.must_equal "github.com"
    subject.user.must_equal "git"
  end

  it "parses a url for the host" do
    subject.url = "github.com:rcarver/config-example.rig"
    subject.host.must_equal "github.com"
    subject.user.must_equal nil
  end
end

