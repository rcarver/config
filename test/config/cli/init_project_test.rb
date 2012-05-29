require 'helper'

describe Config::CLI::InitProject do

  subject { Config::CLI::InitProject }

  specify "#usage" do
    cli.usage.must_equal "test-command"
  end

  describe "#execute" do
    it "executes a blueprint" do
      cli.execute
      blueprints = cli.find_blueprints(Config::Meta::Project)
      blueprints.size.must_equal 1
    end
  end
end


