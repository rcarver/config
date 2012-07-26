require 'helper'

describe Config::Core::GitConfig do

  subject { Config::Core::GitConfig.new }

  describe "setting parts to generate a url" do

    it "generates a url from the parts" do
      subject.user = "git"
      subject.host = "github.com"
      subject.path = "rcarver/config-example.git"
      subject.url.must_equal "git@github.com:rcarver/config-example.git"
    end

    it "generates a url from most of the parts" do
      subject.host = "github.com"
      subject.path = "rcarver/config-example.git"
      subject.url.must_equal "github.com:rcarver/config-example.git"
    end

    it "generates a url with only a path" do
      subject.path = "/tmp/repo"
      subject.url.must_equal "/tmp/repo"
    end

    it "does not generates a url when too few parts are present" do
      subject.host = "github.com"
      subject.url.must_equal nil
    end
  end

  describe "with a url set" do

    before do
      subject.url = "git@github.com:rcarver/config-example.rig"
    end

    it "uses that url" do
      subject.url.must_equal "git@github.com:rcarver/config-example.rig"
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
end

