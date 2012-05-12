require 'helper'

describe "filesystem", Config::Data::Repo do

  let(:source_repo) { tmpdir + "source.git" }
  let(:project_repo) { tmpdir + "project" }

  subject { Config::Data::Repo.new(tmpdir, "project") }

  def create_repo
    source_repo.mkdir
    Dir.chdir(source_repo) do
      `git init .`
      `echo 'hello' > README.md`
      `git add README.md`
      `git commit -m 'hi'`
    end
  end

  describe "#clone" do
    it "clones an existing repo" do
      create_repo
      project_repo.wont_be :exist?
      subject.clone(source_repo)
      project_repo.must_be :exist?
      (project_repo + "README.md").read.must_equal "hello\n"
    end
  end
end

