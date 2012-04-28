require 'helper'

describe Config::Cluster do

  subject { Config::Cluster.new("production") }

  specify "#name" do
    subject.name.must_equal "production"
  end

  specify "#to_s" do
    subject.to_s.must_equal "production cluster"
  end
end
