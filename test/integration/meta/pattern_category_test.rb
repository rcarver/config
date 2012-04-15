require 'helper'

describe Config::Meta::PatternCategory do

  subject { Config::Meta::PatternCategory.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:root, :name]
  end

  specify "validity" do
    subject.root = "/tmp"
    subject.name = "tmp"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Meta::PatternCategory do

  subject { Config::Meta::PatternCategory.new }

  it "creates a new category" do

    subject.root = tmpdir
    subject.name = "nginx"

    execute_pattern

    (tmpdir + "patterns" + "nginx").must_be :exist?

    (tmpdir + "patterns" + "nginx" + "README.md").must_be :exist?
    (tmpdir + "patterns" + "nginx" + "README.md").read.must_equal <<-STR
# Nginx

**TODO** Describe the purpose of this category.
    STR
  end
end

