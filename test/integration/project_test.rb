require 'helper'

describe "filesystem running items", Config::Project do

  subject { Config::Project.new(tmpdir) }

  before do
    (tmpdir + "blueprints").mkdir
    (tmpdir + "blueprints/message.rb").open("w") do |f|
      f.puts <<-STR
        file "#{tmpdir}/file1" do |f|
          f.content = configure.messages.greeting
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

  it "fails if a blueprint is not found" do
    proc { subject.try_blueprint("something", "production") }.must_raise Config::Project::UnknownBlueprint
  end

  it "fails if a cluster is not found" do
    proc { subject.try_blueprint("message", "other") }.must_raise Config::Project::UnknownCluster
  end

  it "works if the relative path to a blueprint is given" do
    proc { subject.try_blueprint("blueprints/message") }.must_raise ArgumentError
    proc { subject.try_blueprint("foo/message.rb") }.must_raise ArgumentError
    subject.try_blueprint("blueprints/message.rb")
  end

  it "works if the relative path to a cluster is given" do
    proc { subject.try_blueprint("message", "clusters/production") }.must_raise ArgumentError
    proc { subject.try_blueprint("foo/production.rb") }.must_raise ArgumentError
    subject.try_blueprint("message", "clusters/production.rb")
  end

  describe "#try_blueprint with blueprint and cluster" do

    it "executes the blueprint in noop mode" do
      subject.try_blueprint("message", "production")
      log_string.must_include("Create [File #{tmpdir}/file1]")
      (tmpdir + "file1").wont_be :exist?
    end
  end
end

describe "filesystem loading assets", Config::Project do

  subject { Config::Project.new(tmpdir) }

  describe "#hub" do

    it "has no git urls by default" do
      subject.hub.project_config.url.must_equal nil
      subject.hub.data_config.url.must_equal nil
    end

    it "sets git urls from the current repo" do
      (tmpdir + ".git").mkdir
      (tmpdir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      subject.hub.project_config.url.must_equal 'git@github.com:foo/bar.git'
      subject.hub.data_config.url.must_equal    'git@github.com:foo/bar-data.git'
    end

    it "uses a hub file" do
      (tmpdir + "hub.rb").open("w") do |f|
        f.puts "project_repo 'git@github.com:foo/bar.git'"
      end
      subject.hub.project_config.url.must_equal 'git@github.com:foo/bar.git'
      subject.hub.data_config.url.must_equal    'git@github.com:foo/bar-data.git'
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

  describe "#require_patterns" do

    it "loads all patterns" do
      (tmpdir + "patterns/project_test1").mkpath
      (tmpdir + "patterns/project_test1/pattern1.rb").open("w") do |f|
        f.puts "class ProjectTest1::Pattern1 < Config::Pattern; end"
      end
      (tmpdir + "patterns/project_test1/pattern2.rb").open("w") do |f|
        f.puts "class ProjectTest1::Pattern2 < Config::Pattern; end"
      end
      (tmpdir + "patterns/project_test2").mkpath
      (tmpdir + "patterns/project_test2/pattern1.rb").open("w") do |f|
        f.puts "class ProjectTest2::Pattern2 < Config::Pattern; end"
      end

      subject.require_patterns

      assert defined?(ProjectTest1::Pattern1)
      assert defined?(ProjectTest1::Pattern2)
      assert defined?(ProjectTest2::Pattern2)
    end

    it "fails to load a pattern with a syntax error" do
      (tmpdir + "patterns/project_test1").mkpath
      (tmpdir + "patterns/project_test1/pattern1.rb").open("w") do |f|
        f.puts "class ProjectTest1::Pattern1"
      end

      proc { subject.require_patterns }.must_raise(SyntaxError)
    end
  end

  describe "#require_clusters" do

    it "loads all clusters" do
      (tmpdir + "clusters").mkdir
      (tmpdir + "clusters/one.rb").open("w") do |f|
        f.puts "configure :test, :key => 123"
      end
      (tmpdir + "clusters/two.rb").open("w") do |f|
        f.puts "configure :other, :key => 456"
      end

      subject.require_clusters

      subject.clusters["one"].configuration.test.key.must_equal 123
      subject.clusters["two"].configuration.other.key.must_equal 456
    end

    it "fails to load a cluster with a syntax error" do
      (tmpdir + "clusters").mkdir
      (tmpdir + "clusters/test.rb").open("w") do |f|
        f.puts "x, y"
      end

      proc { subject.require_clusters }.must_raise(SyntaxError)
    end
  end

  describe "#require_blueprints" do

    it "loads all blueprints" do
      (tmpdir + "blueprints").mkdir
      (tmpdir + "blueprints/one.rb").open("w") do |f|
        f.puts "file \"/tmp/file1\""
      end
      (tmpdir + "blueprints/two.rb").open("w") do |f|
        f.puts "file \"/tmp/file2\""
      end

      subject.require_blueprints
      subject.blueprints["one"].must_be_instance_of Config::Blueprint
      subject.blueprints["two"].must_be_instance_of Config::Blueprint
    end

    it "exposes the error" do
      (tmpdir + "blueprints").mkdir
      (tmpdir + "blueprints/test.rb").open("w") do |f|
        f.puts "x, y"
      end

      skip "this doesn't work because blueprint evaluation doesn't occur until accumulation"
      proc { subject.require_blueprints }.must_raise(SyntaxError)
    end
  end
end
