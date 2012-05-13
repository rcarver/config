require 'helper'

describe Config::Node do

  let(:cluster)   { :production }
  let(:blueprint) { :webserver }
  let(:identity)  { "xyz" }

  subject { Config::Node.new(cluster, blueprint, identity) }

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
