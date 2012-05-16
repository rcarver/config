require 'helper'

describe Config::Node do

  let(:cluster_name)   { "production" }
  let(:blueprint_name) { "webserver" }
  let(:identity)       { "xyz" }

  let(:facts_data) { 
    { "ec2" => { "public_ipv4" => "127.0.0.1" } }
  }

  subject { Config::Node.new(cluster_name, blueprint_name, identity) }

  before do
    subject.facts = Config::Core::Facts.new(facts_data)
  end

  specify "#fqn" do
    subject.fqn.must_equal "production-webserver-xyz"
  end

  specify "equality" do
    a = Config::Node.new("a", "b", "c")
    b = Config::Node.new("a", "b", "c")
    c = Config::Node.new("a", "b", "x")

    a.must_equal b
    b.must_equal a
    a.wont_equal c
    c.wont_equal a

    b.facts = Config::Core::Facts.new("info" => "here")

    a.wont_equal b
    b.wont_equal a
  end

  specify "#as_json" do
    subject.as_json.must_equal(
      node: {
        cluster: cluster_name,
        blueprint: blueprint_name,
        identity: identity,
      },
      facts: facts_data
    )
  end

  specify ".from_json" do
    json = JSON.load(JSON.dump(subject.as_json))
    node = Config::Node.from_json(json)
    node.cluster_name.must_equal "production"
    node.blueprint_name.must_equal "webserver"
    node.identity.must_equal "xyz"
    node.facts.ec2.public_ipv4.must_equal "127.0.0.1"
  end
end
