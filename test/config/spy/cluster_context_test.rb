require 'helper'

describe Config::Spy::ClusterContext do

  subject { Config::Spy::ClusterContext.new }

  it "logs when the name is accessed" do
    subject.name.must_equal "fake_cluster"
    log_string.must_equal %(Read cluster.name => "fake:cluster"\n)
  end

end

