require 'helper'

describe Config::Cluster do

  subject { Config::Cluster.new("production") }

  specify "#name" do
    subject.name.must_equal "production"
  end

  specify "#to_s" do
    subject.to_s.must_equal "production cluster"
  end

  it "provides access to variables" do
    subject.variables = { :webserver => :vars }
    subject.webserver.must_equal :vars
  end
end
