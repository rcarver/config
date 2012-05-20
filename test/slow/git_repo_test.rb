require 'helper'

describe "filesystem", Config::Core::GitRepo do

  describe "working with the index" do

    let(:project_dir) { tmpdir + "project" }

    subject { Config::Core::GitRepo.new(tmpdir + "project") }

    before do
      project_dir.mkdir
      within(project_dir) do
        cmd "git init ."
        cmd "echo hello > README.md"
        cmd "git add README.md"
        cmd "git commit -m 'here we go'"
      end
    end

    describe "#describe_head" do
      it "returns the SHA and commit message" do
        sha, message = subject.describe_head
        sha.must_match /^[a-z0-9]+$/
        message.must_equal "here we go"
      end
    end

    describe "#add" do

      before do
        within(project_dir) { `echo world >> README.md` }
      end

      it "stages changes to file" do
        subject.add "."
        within(project_dir) do
          cmd("git status") .must_include "Changes to be committed"
        end
      end
    end

    describe "#rm" do

      before do
        subject.rm "README.md"
      end

      it "stages removal of a file" do
        within(project_dir) do
          cmd("git status") .must_include "Changes to be committed"
        end
      end
    end

    describe "#reset_hard" do

      before do
        within(project_dir) { `echo world >> README.md` }
      end

      it "stages changes to file" do
        subject.reset_hard
        within(project_dir) do
          cmd("git status").must_include "nothing to commit"
        end
      end
    end

    describe "#commit" do

      before do
        within(project_dir) { `echo world >> README.md` }
      end

      it "fails if there is nothing to commit" do
        proc { subject.commit "okok" }.must_raise Config::Core::GitRepo::CommitError
      end

      it "commits changes" do
        subject.add "."
        subject.commit "okok"
        within(project_dir) do
          cmd("git status").must_include "nothing to commit"
        end
      end
    end

    describe "#clean_status?" do

      before do
        within(project_dir) { `echo world >> README.md` }
      end

      it "is false with an edited file" do
        subject.wont_be :clean_status?
      end

      it "is false when a file is added to the index" do
        subject.add "."
        subject.wont_be :clean_status?
      end

      it "is true when the file is committed" do
        subject.add "."
        subject.commit "okok"
        subject.must_be :clean_status?
      end

      it "is false when a new file is added" do
        subject.add "."
        subject.commit "okok"
        within(project_dir) { `echo hello >> new_file` }
        subject.wont_be :clean_status?
      end
    end
  end

  describe "working with remotes" do

    let(:source_dir) { tmpdir + "source.git" }
    let(:project1_dir) { tmpdir + "project1" }
    let(:project2_dir) { tmpdir + "project2" }

    let(:project1) { Config::Core::GitRepo.new(tmpdir + "project1") }
    let(:project2) { Config::Core::GitRepo.new(tmpdir + "project2") }

    it "works" do
      source_dir.mkdir
      within(source_dir) do
        cmd "git init --bare"
      end

      # clone source to project1
      cmd "git clone #{source_dir} #{project1_dir}"

      # clone source to project2
      cmd "git clone #{source_dir} #{project2_dir}"

      # update project1
      # NOTE: problems pulling a repo with no commit.
      #project1.pull_rebase

      # commit and push from project1
      within(project1_dir) { cmd "echo hello > one" }
      project1.add "."
      project1.commit "commit-from-1"
      project1.push

      # commit and push from project2 with state resolution
      within(project2_dir) { cmd "echo goodbye > two" }
      project2.add "."
      project2.commit "commit-from-2"
      proc { project2.push }.must_raise Config::Core::GitRepo::PushError
      project2.pull_rebase
      (project2_dir + "one").must_be :exist?
      project2.push

      # pull changes into project1
      project1.pull_rebase
      (project2_dir + "two").must_be :exist?

      # Show that there are only two commits (no merge).
      within(project1_dir) do
        lines = cmd "git log --oneline"
        messages = lines.split("\n").map { |line| line.split(/\s/).last }
        messages.must_equal [
          "commit-from-2",
          "commit-from-1"
        ]
      end
    end
  end
end

