require 'helper'

describe Config::Meta::PatternTopic do

  subject { Config::Meta::PatternTopic.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:root, :name]
  end

  specify "validity" do
    subject.root = "/tmp"
    subject.name = "tmp"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Meta::PatternTopic do

  subject { Config::Meta::PatternTopic.new }

  it "creates a new topic" do

    subject.root = tmpdir
    subject.name = "nginx"

    execute_pattern

    (tmpdir + "patterns" + "nginx").must_be :exist?

    (tmpdir + "patterns" + "nginx" + "README.md").must_be :exist?
    (tmpdir + "patterns" + "nginx" + "README.md").read.must_equal <<-STR.dent
      # Nginx

      **TODO** Describe the purpose of this topic.
    STR
  end
end

