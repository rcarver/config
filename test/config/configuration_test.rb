require 'helper'

describe Config::Configuration do

  specify ".new" do
    Config::Configuration.new.must_be_instance_of Levels::Level
  end

  specify ".merge" do
    Config::Configuration.merge([]).must_be_instance_of Levels::Merged
  end
end
