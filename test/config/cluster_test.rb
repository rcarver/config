require 'helper'

describe Config::Cluster do

  let(:blueprint_vars) { {} }

  subject { Config::Cluster.new(blueprint_vars) }

  it "provides access to each blueprint's vars" do
    blueprint_vars[:webserver] = :vars
    subject.webserver.must_equal :vars
  end
end
