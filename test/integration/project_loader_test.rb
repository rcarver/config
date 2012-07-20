require 'helper'

describe "filesystem", Config::ProjectLoader do

  subject { Config::ProjectLoader.new(tmpdir) }

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

  describe "#require_global" do

    it "loads nothing when no file exists" do
      subject.require_global
    end

    it "loads the config" do
      (tmpdir + "config.rb").open("w") do |f|
        f.puts "configure :test, :key => 123"
      end

      subject.require_global
      subject.get_global.configuration.test.key.must_equal 123
    end

    it "fails to load a config with a syntax error" do
      (tmpdir + "config.rb").open("w") do |f|
        f.puts "x, y"
      end

      proc { subject.require_global }.must_raise(SyntaxError)
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

      subject.get_cluster("one").configuration.test.key.must_equal 123
      subject.get_cluster("two").configuration.other.key.must_equal 456
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
      subject.get_blueprint("one").must_be_instance_of Config::Blueprint
      subject.get_blueprint("two").must_be_instance_of Config::Blueprint
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

  describe "#get_global" do

    it "returns nil when no file exists" do
      subject.get_global.must_equal nil
    end

    it "returns the configured global from disk" do
      (tmpdir + "config.rb").open("w") do |f|
        f.puts "configure :test, :ok => 123"
      end
      subject.get_global.configuration.test.ok.must_equal 123
    end
  end

  describe "#get_blueprint" do

    before do
      (tmpdir + "blueprints").mkdir
      (tmpdir + "blueprints/message.rb").open("w")

      subject.require_blueprints
    end

    it "returns a blueprint" do
      subject.get_blueprint("message").must_be_instance_of Config::Blueprint
      subject.get_blueprint("blueprints/message.rb").must_be_instance_of Config::Blueprint
    end

    it "returns nil if a blueprint is not found" do
      subject.get_blueprint("something").must_equal nil
    end

    it "fails if a path is given that doesn't point to a file" do
      proc { subject.get_blueprint("blueprints/message") }.must_raise ArgumentError
      proc { subject.get_blueprint("foo/message.rb") }.must_raise ArgumentError
    end
  end

  describe "#get_cluster" do

    before do
      (tmpdir + "clusters").mkdir
      (tmpdir + "clusters/production.rb").open("w")

      subject.require_clusters
    end

    it "returns a cluster" do
      subject.get_cluster("production").must_be_instance_of Config::Cluster
      subject.get_cluster("clusters/production.rb").must_be_instance_of Config::Cluster
    end

    it "returns nil if a cluster is not found" do
      subject.get_cluster("other").must_equal nil
    end

    it "fails if a path is given that doesn't point to a file" do
      proc { subject.get_cluster("clusters/production") }.must_raise ArgumentError
      proc { subject.get_cluster("foo/production.rb") }.must_raise ArgumentError
    end
  end
end
