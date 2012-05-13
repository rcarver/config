require 'helper'

describe "filesystem", Config::Data::GitDatabase do

  let(:repo) { MiniTest::Mock.new }

  subject { Config::Data::GitDatabase.new(tmpdir, repo) }

  let(:node) { MiniTest::Mock.new }

  before do
    node.expect(:fqn, "prod-webserver-1")
  end

  after do
    repo.verify
  end

  let(:facts_dir)  { tmpdir + "facts" }
  let(:facts_file) { tmpdir + "facts/prod-webserver-1.json" }

  describe "#update" do

    it "pulls the repo" do
      repo.expect(:reset_hard, nil)
      repo.expect(:pull_rebase, nil)
      subject.update
    end
  end

  describe "#update_node" do

    before do
      node.expect(:facts, { a: 1 })
      repo.expect(:reset_hard, nil)
      repo.expect(:add, nil, [facts_file])
      repo.expect(:push, nil)
    end

    it "creates a facts file" do
      repo.expect(:commit, nil, ["Added node prod-webserver-1"])
      subject.update_node(node)
      facts_file.must_be :exist?
      facts_file.read.must_equal %({"a":1})
    end

    it "updates a facts file" do
      facts_dir.mkpath
      facts_file.open("w") do |f|
        f.print "ok"
      end
      repo.expect(:commit, nil, ["Updated node prod-webserver-1"])
      subject.update_node(node)
    end
  end

  describe "#remove_node" do

    it "removes an existing facts file" do
      facts_dir.mkpath
      facts_file.open("w") do |f|
        f.print "ok"
      end
      repo.expect(:reset_hard, nil)
      repo.expect(:rm, nil, [facts_file])
      repo.expect(:commit, nil, ["Removed node prod-webserver-1"])
      repo.expect(:push, nil)
      subject.remove_node(node)
    end

    it "ignores a non-existent facts file" do
      subject.remove_node(node)
    end
  end

  describe "handling git push conflicts" do

    let(:failed_push_class) {
      Class.new do

        attr_reader :pushes

        def push
          @pushes ||= 0
          @pushes += 1
          case @pushes
          when 1, 2 then raise Config::Data::Repo::PushError
          else nil
          end
        end

        attr_reader :pulls

        def pull_rebase
          @pulls ||= 0
          @pulls += 1
        end
      end
    }

    let(:repo) { SimpleMock.new(failed_push_class.new) }

    it "retries until the push succeeds" do
      repo.expect(:reset_hard, nil)
      subject.send(:txn) do
        # nothing
      end
      repo.pushes.must_equal 3
      repo.pulls.must_equal 2
    end
  end
end
