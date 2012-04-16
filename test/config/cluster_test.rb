require 'helper'

describe Config::Cluster do

  let(:blueprint_vars) { {} }

  subject { Config::Cluster.new("production", blueprint_vars) }

  it "#to_s" do
    subject.to_s.must_equal "production cluster"
  end

  it "provides access to each blueprint's vars" do
    blueprint_vars[:webserver] = :vars
    subject.webserver.must_equal :vars
  end
end
