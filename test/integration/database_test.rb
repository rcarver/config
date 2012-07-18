require 'helper'

describe "filesystem", Config::Database do

  let(:repo) { MiniTest::Mock.new }
  let(:node) { Config::Node.new("prod", "webserver", "1") }

  subject { Config::Database.new(tmpdir, repo) }

  after do
    repo.verify
  end

  let(:node_dir)  { tmpdir + "nodes" }
  let(:node_file) { tmpdir + "nodes/prod-webserver-1.json" }

  describe "#update" do

    it "pulls the repo" do
      repo.expect(:reset_hard, nil)
      repo.expect(:pull_rebase, nil)
      repo.expect(:describe_head, ["a", "message"])
      subject.update
      log_string.must_equal <<-STR
Database updated. Now at: a "message"
       STR
    end
  end

  describe "#find_node" do

    it "instantiates a node from disk" do
      node_file.dirname.mkpath
      node_file.open("w") do |f|
        f.print JSON.dump(node.as_json)
      end
      found = subject.find_node(node.fqn)
      found.must_equal node
    end

    it "returns nil if no node exists" do
      found = subject.find_node(node.fqn)
      found.must_equal nil
    end
  end

  describe "#update_node" do

    before do
      repo.expect(:reset_hard, nil)
      repo.expect(:add, nil, [node_file])
      repo.expect(:push, nil)
    end

    it "creates a node file" do
      repo.expect(:commit, nil, ["add node prod-webserver-1"])
      subject.update_node(node)
      node_file.must_be :exist?
      # We care about the presentation of this file so 
      # that diffs are efficient.
      node_file.read.must_equal <<-STR.chomp
{
  "node": {
    "cluster": "prod",
    "blueprint": "webserver",
    "identity": "1"
  },
  "facts": {
  }
}
      STR
      log_string.must_equal <<-STR
Database commit: add node prod-webserver-1
Database pushed
      STR
    end

    it "updates a nodes file" do
      node_dir.mkpath
      node_file.open("w") do |f|
        f.print "ok"
      end
      repo.expect(:commit, nil, ["update node prod-webserver-1"])
      subject.update_node(node)
      log_string.must_equal <<-STR
Database commit: update node prod-webserver-1
Database pushed
      STR
    end
  end

  describe "#remove_node" do

    it "removes an existing nodes file" do
      node_dir.mkpath
      node_file.open("w") do |f|
        f.print "ok"
      end
      repo.expect(:reset_hard, nil)
      repo.expect(:rm, nil, [node_file])
      repo.expect(:commit, nil, ["remove node prod-webserver-1"])
      repo.expect(:push, nil)
      subject.remove_node(node)
      log_string.must_equal <<-STR
Database commit: remove node prod-webserver-1
Database pushed
      STR
    end

    it "ignores a non-existent nodes file" do
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
          when 1, 2 then raise Config::Core::GitRepo::PushError
          else nil
          end
        end

        attr_reader :pulls

        def pull_rebase
          @pulls ||= 0
          @pulls += 1
        end

        def describe_head
          case @pulls
          when 1 then ["1", "message one"]
          when 2 then ["2", "message two"]
          end
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
      log_string.must_equal <<-STR
Database pulled to resolve remote changes. Now at: 1 "message one"
Database pulled to resolve remote changes. Now at: 2 "message two"
Database pushed
      STR
    end
  end
end
