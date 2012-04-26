require 'helper'

describe Config::Meta::Cluster do

  subject { Config::Meta::Cluster.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:root, :name]
  end

  specify "validity" do
    subject.root = "/tmp"
    subject.name = "tmp"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Meta::Cluster do

  subject { Config::Meta::Cluster.new }

  it "creates a new cluster" do

    subject.root = tmpdir
    subject.name = "production"

    execute_pattern

    (tmpdir + "clusters" + "production.rb").must_be :exist?
    (tmpdir + "clusters" + "production.rb").read.must_equal <<-STR
blueprint :some_blueprint,
  :key1 => 123,
  :key2 => "value"
    STR
  end
end


