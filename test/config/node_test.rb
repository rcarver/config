require 'helper'

describe Config::Node do

  let(:cluster_name)   { :production }
  let(:blueprint_name) { :webserver }
  let(:identity)       { "xyz" }

  subject { Config::Node.new(cluster_name, blueprint_name, identity) }

  specify "#fqn" do
    subject.fqn.must_equal "production-webserver-xyz"
  end

  specify "#as_json" do
    subject.as_json.must_equal({
      cluster: "production",
      blueprint: "webserver",
      identity: "xyz",
      facts: {}
    })
  end
end
