require 'helper'

describe Config::Bootstrap::System do

  subject { Config::Bootstrap::System.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal []
  end

  specify "validity" do
    subject.path = "/tmp/file"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Bootstrap::System do

  subject { Config::Bootstrap::System.new }

  it "writes a script" do

    subject.path = tmpdir + "system"
    subject.git_version = "1.7"
    subject.ruby_version = "1.9"
    subject.rubygems_version = "1.8"
    subject.bundler_version = "1.1"

    execute_pattern

    (tmpdir + "system").must_be :exist?
    contents = (tmpdir + "system").read

    contents.must_include "install git-core=1:1.7-1ubuntu0.2"
    contents.must_include "ruby-1.9.tar.gz"
    contents.must_include "rubygems-1.8.tgz"
    contents.must_include "gem install bundler --version 1.1"
  end
end


