require 'helper'

describe Config::Project do

  subject { Config::Project.new("/tmp", "/tmp") }

  describe "#update" do

    let(:git_repo) { MiniTest::Mock.new }

    before do
      subject.git_repo = git_repo
    end

    after do
      git_repo.verify
    end

    it "returns :dirty if the repo isn't clean" do
      git_repo.expect(:clean_status?, false)

      subject.update.must_equal :dirty
    end

    it "returns :updated and updates the repo" do
      git_repo.expect(:clean_status?, true)
      git_repo.expect(:reset_hard, nil)
      git_repo.expect(:pull_rebase, nil)

      subject.update.must_equal :updated
    end
  end
end
