require 'helper'

describe "filesystem running items", Config::Project do

  subject { Config::Project.new(tmpdir, tmpdir + ".data") }

  describe "executing a blueprint" do

    before do
      (tmpdir + "blueprints").mkdir
      (tmpdir + "blueprints/message.rb").open("w") do |f|
        f.puts <<-STR
          file "#{tmpdir}/file1" do |f|
            f.content = configure.messages.greeting
          end
          file "#{tmpdir}/file2" do |f|
            f.content = node.ec2.ip_address
          end
        STR
      end

      (tmpdir + "clusters").mkdir
      (tmpdir + "clusters/production.rb").open("w") do |f|
        f.puts <<-STR
          configure :messages,
            greeting: "hello world"
        STR
      end
    end

    describe "#try_blueprint" do

      it "executes the blueprint in noop mode" do
        subject.try_blueprint("message", "production")
        log_string.must_include("Create [File #{tmpdir}/file1]")
        log_string.must_include("Create [File #{tmpdir}/file2]")
        log_string.must_include("hello world")
        (tmpdir + "file1").wont_be :exist?
        (tmpdir + "file2").wont_be :exist?
      end

      it "executes the blueprint with a spy cluster and spy node" do
        subject.try_blueprint("message")
        log_string.must_include("Create [File #{tmpdir}/file1]")
        log_string.must_include("Create [File #{tmpdir}/file2]")
        log_string.must_include("fake:messages.greeting")
        log_string.must_include("fake:ec2.ip_address")
        (tmpdir + "file1").wont_be :exist?
        (tmpdir + "file2").wont_be :exist?
      end
    end

    describe "#execute_node" do

      let(:node) { Config::Node.new("production", "message", "one") }
      let(:facts) { Config::Core::Facts.new("ec2" => { "ip_address" => "127.0.0.1" }) }
      let(:database) { MiniTest::Mock.new }

      before do
        node.facts = facts
        subject.database = database
      end

      after do
        database.verify
      end

      it "executes the blueprint" do
        database.expect(:find_node, node, [node.fqn])
        subject.execute_node(node.fqn)
        (tmpdir + "file1").read.must_equal "hello world"
        (tmpdir + "file2").read.must_equal "127.0.0.1"
      end

      it "executes the blueprint with a previous accumulation" do
        skip "TODO"
      end
    end
  end

  describe "#data_dir" do

    it "creates the dir" do
      subject.data_dir
      (tmpdir + ".data").must_be :exist?
    end

    it "does nothing if the dir exists" do
      (tmpdir + ".data").mkdir
      subject.data_dir
    end

    it "can read a secret" do
      subject.data_dir
      (tmpdir + ".data/secret-default").open("w") do |f|
        f.print "shh"
      end
      subject.data_dir.secret(:default).read.must_equal "shh"
    end
  end

  describe "#get_node" do

    let(:node) { Config::Node.new("production", "message", "one") }

    before do
      (tmpdir + ".data/project-data/nodes").mkpath
      (tmpdir + ".data/project-data/nodes/production-message-one.json").open("w") do |f|
        f.print JSON.dump(node.as_json)
      end
    end

    it "returns a node" do
      subject.get_node("production-message-one").must_be_instance_of Config::Node
    end

    it "fails if a node is not found" do
      proc { subject.get_node("other") }.must_raise Config::Project::UnknownNode
    end
  end
end
