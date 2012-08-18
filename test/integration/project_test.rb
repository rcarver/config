require 'helper'

describe "filesystem running items", Config::Project do

  let(:project_loader) { Config::ProjectLoader.new(tmpdir) }
  let(:private_data)   { Config::PrivateData.new(tmpdir + ".data") }
  let(:nodes)          { MiniTest::Mock.new }

  subject { Config::Project.new(project_loader, private_data, nodes) }

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
          file "#{tmpdir}/file3" do |f|
            f.content = cluster.name
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
        log_string.must_include("+ [File #{tmpdir}/file1]")
        log_string.must_include("+ [File #{tmpdir}/file2]")
        log_string.must_include("+ [File #{tmpdir}/file3]")
        log_string.must_include("hello world")
        (tmpdir + "file1").wont_be :exist?
        (tmpdir + "file2").wont_be :exist?
        (tmpdir + "file3").wont_be :exist?
      end

      it "executes the blueprint with a spy configuration, cluster, and node" do
        subject.try_blueprint("message")
        log_string.must_include("+ [File #{tmpdir}/file1]")
        log_string.must_include("+ [File #{tmpdir}/file2]")
        log_string.must_include("+ [File #{tmpdir}/file3]")
        log_string.must_include("spy:messages.greeting")
        log_string.must_include("fake:ec2.ip_address")
        log_string.must_include("fake:spy_cluster")
        (tmpdir + "file1").wont_be :exist?
        (tmpdir + "file2").wont_be :exist?
        (tmpdir + "file3").wont_be :exist?
      end
    end

    describe "#execute_node" do

      let(:node) { Config::Node.new("production", "message", "one") }
      let(:facts) { Config::Facts.new("ec2" => { "ip_address" => "127.0.0.1" }) }

      before do
        node.facts = facts
      end

      it "executes the blueprint" do
        nodes.expect(:get_node, node, [node.fqn])
        subject.execute_node(node.fqn)
        (tmpdir + "file1").read.must_equal "hello world"
        (tmpdir + "file2").read.must_equal "127.0.0.1"
        (tmpdir + "file3").read.must_equal "production"
      end

      it "executes the blueprint with a previous accumulation" do
        skip "TODO"
      end
    end
  end
end
