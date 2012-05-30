require 'helper'

describe Config::CLI::UpdateProject do

  subject { Config::CLI::UpdateProject }

  specify "#usage" do
    cli.usage.must_equal "test-command"
  end

  describe "#execute" do
    it "exec's a script" do
      project.expect(:update_project_script, "echo yay")
      kernel.expect(:exec, nil, [/echo yay/])
      cli.execute
    end
  end
end





