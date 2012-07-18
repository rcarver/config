require 'helper'

describe Config::Bootstrap::Project do

  subject { Config::Bootstrap::Project.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:git_uri]
  end

  specify "validity" do
    subject.path = "/tmp/file"
    subject.git_uri = "git@github.com:test/this.git"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Bootstrap::Project do

  subject { Config::Bootstrap::Project.new }

  it "writes a script" do

    subject.path = tmpdir + "config"
    subject.git_uri = "git@github.com:test/this.git"

    execute_pattern

    (tmpdir + "config").must_be :exist?
    contents = (tmpdir + "config").read

    contents.must_include "git clone git@github.com:test/this.git project"
    contents.must_include "bundle install"
  end
end
