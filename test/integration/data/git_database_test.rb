require 'helper'

describe "filesystem", Config::Data::GitDatabase do

  let(:repo) { MiniTest::Mock.new }
  let(:node) { Config::Node.new("prod", "webserver", "1") }

  subject { Config::Data::GitDatabase.new(tmpdir, repo) }

  after do
    repo.verify
  end

  let(:node_dir)  { tmpdir + "nodes" }
  let(:node_file) { tmpdir + "nodes/prod-webserver-1.json" }

  describe "#update" do

    it "pulls the repo" do
      repo.expect(:reset_hard, nil)
      repo.expect(:pull_rebase, nil)
      subject.update
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
      repo.expect(:commit, nil, ["Added node prod-webserver-1"])
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
    end

    it "updates a nodes file" do
      node_dir.mkpath
      node_file.open("w") do |f|
        f.print "ok"
      end
      repo.expect(:commit, nil, ["Updated node prod-webserver-1"])
      subject.update_node(node)
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
      repo.expect(:commit, nil, ["Removed node prod-webserver-1"])
      repo.expect(:push, nil)
      subject.remove_node(node)
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
