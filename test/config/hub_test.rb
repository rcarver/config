require 'helper'

describe Config::Hub do

  subject { Config::Hub.new }

  before do
    subject.git_project_url = "git@github.com:user/project.git"
  end

  specify "#git_ssh_host" do
    subject.git_ssh_host.must_equal "github.com"
  end

  specify "#git_ssh_port" do
    subject.git_ssh_port.must_equal "22"
  end

  specify "#git_ssh_user" do
    subject.git_ssh_user.must_equal "git"
  end
end
