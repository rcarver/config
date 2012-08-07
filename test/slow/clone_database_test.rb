require 'helper'

describe "filesystem", Config::Meta::CloneDatabase do

  subject { Config::Meta::CloneDatabase.new }

  let(:project_dir) { tmpdir + "project" }
  let(:repo_dir) { tmpdir + "repo" }

  before do
    repo_dir.mkdir
    within(repo_dir) do
      cmd "git init --bare"
    end
  end

  it "clones once" do

    subject.url = repo_dir
    subject.path = project_dir

    execute_pattern
    log_string.must_include "Cloning into"
    log_string.must_include project_dir.to_s

    (project_dir + ".git").must_be :exist?

    execute_pattern
  end
end
