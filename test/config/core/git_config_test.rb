require 'helper'

describe Config::Core::GitConfig do

  subject { Config::Core::GitConfig.new }

  before do
    subject.url = "git@github.com:rcarver/config-example.rig"
  end

  it "parses a url for the user and host" do
    subject.host.must_equal "github.com"
    subject.user.must_equal "git"
  end

  it "parses a url for the host only" do
    subject.url = "github.com:rcarver/config-example.rig"
    subject.host.must_equal "github.com"
    subject.user.must_equal nil
  end

  it "allows the host to be set" do
    subject.host = "example.com"
    subject.host.must_equal "example.com"
  end

  it "allows the user to be set" do
    subject.user = "root"
    subject.user.must_equal "root"
  end
end

