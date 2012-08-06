require 'helper'

describe Config::Global do

  subject { Config::Global.new }

  specify "#to_s" do
    subject.to_s.must_equal "Config"
  end

  specify "the configuration name" do
    subject.configuration._level_name.must_equal "Global"
  end
end

