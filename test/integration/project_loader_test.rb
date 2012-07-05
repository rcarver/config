require 'helper'

describe "filesystem", Config::ProjectLoader do

  subject { Config::ProjectLoader.new(tmpdir) }

  describe "#get_hub" do

    let(:hub) { subject.get_hub }

    it "has no git urls by default" do
      hub.project_config.url.must_equal nil
      hub.data_config.url.must_equal nil
    end

    it "sets git urls from the current repo" do
      (tmpdir + ".git").mkdir
      (tmpdir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      hub.project_config.url.must_equal 'git@github.com:foo/bar.git'
      hub.data_config.url.must_equal    'git@github.com:foo/bar-data.git'
    end

    it "uses a hub file" do
      (tmpdir + "hub.rb").open("w") do |f|
        f.puts "project_repo 'git@github.com:foo/bar.git'"
      end
      hub.project_config.url.must_equal 'git@github.com:foo/bar.git'
      hub.data_config.url.must_equal    'git@github.com:foo/bar-data.git'
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
