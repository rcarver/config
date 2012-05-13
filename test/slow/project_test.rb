require 'helper'

describe "filesystem", Config::Project do

  let(:project_dir) { tmpdir + "project" }

  before do
    project_dir.mkdir
  end

  subject { Config::Project.new(project_dir) }

  describe "#clone_data_repo" do

    let(:repo_dir) { tmpdir + "repo" }

    before do
      repo_dir.mkdir
      within(repo_dir) do
        cmd "git init --bare"
      end
      (project_dir + "hub.rb").open("w") do |f|
        f.print %(git_data "#{repo_dir}")
      end
    end

    it "clones the repo once" do
      subject.clone_data_repo
      (project_dir + ".data/project-data/.git").must_be :exist?
      subject.clone_data_repo
    end
  end
end
