require 'helper'

describe Config::Meta::Project do

  subject { Config::Meta::Project.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:root]
  end

  specify "validity" do
    subject.root = "/tmp"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Meta::Project do

  subject { Config::Meta::Project.new }

  it "creates a new project" do

    subject.root = tmpdir

    execute_pattern

    (tmpdir + ".gitignore").must_be :exist?
    (tmpdir + ".gitignore").read.must_equal <<-STR
.data
    STR

    (tmpdir + ".data").must_be :exist?

    (tmpdir + "blueprints").must_be :exist?
    (tmpdir + "patterns").must_be :exist?
    (tmpdir + "facts").must_be :exist?
    (tmpdir + "clusters").must_be :exist?

    (tmpdir + "README.md").must_be :exist?
    (tmpdir + "README.md").read.must_equal <<-STR
# MyProject

This project is powered by [Config](https://github.com/rcarver/config).
    STR
  end

  it "does not overwrite the readme" do

    # README should exist.
    (tmpdir + "README.md").open("w") do |f|
      f.print "hello"
    end

    subject.root = tmpdir

    execute_pattern

    (tmpdir + "README.md").read.must_equal "hello"
  end
end

