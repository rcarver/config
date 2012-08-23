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
    subject.facts = Config::Facts.new(facts_data)
  end

  specify "#fqn" do
    subject.fqn.must_equal "production-webserver-xyz"
  end

  specify "equality" do
    a = Config::Node.new("a", "b", "c")
    b = Config::Node.new("a", "b", "c")
    c = Config::Node.new("a", "b", "x")

    (a == b).must_equal true
    (b == a).must_equal true
    (a == c).must_equal false
    (c == a).must_equal false

    (a.eql? b).must_equal true
    (b.eql? a).must_equal true
    (a.eql? c).must_equal false
    (c.eql? a).must_equal false

    b.facts = Config::Facts.new("info" => "here")

    (a == b).must_equal true
    (a.eql? b).must_equal true
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

  describe ".from_fqn" do

    it "parses an fqn" do
      result = Config::Node.from_fqn(subject.fqn)
      result.must_equal subject
    end

    it "parses a fqdn" do
      result = Config::Node.from_fqn(subject.fqn + ".example.com")
      result.must_equal subject
      result = Config::Node.from_fqn(subject.fqn + ".internal.example.com")
      result.must_equal subject
    end

    it "errors if the input is not an fqn" do
      proc { Config::Node.from_fqn("a-b") }.must_raise ArgumentError
      proc { Config::Node.from_fqn("a-b-c-d") }.must_raise ArgumentError
      proc { Config::Node.from_fqn("") }.must_raise ArgumentError
      proc { Config::Node.from_fqn(nil) }.must_raise ArgumentError
    end
  end
end
