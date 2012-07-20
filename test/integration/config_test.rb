require 'helper'

describe "filesystem", Config do

  let(:system_dir) { tmpdir + "system" }

  before do
    @current_dir = Dir.pwd
    Dir.chdir tmpdir
  end

  after do
    Dir.chdir @current_dir
  end

  def setup_system_dir
    system_dir.mkdir
    Config.system_dir = system_dir
  end

  specify ".system_dir" do
    Config.system_dir.must_equal Pathname.new("/etc/config")
  end

  describe ".project_dir" do
    it "loads from the system dir" do
      setup_system_dir
      Config.project_dir.must_equal system_dir + "project"
    end
    it "loads from the local dir" do
      Config.project_dir.must_equal Pathname.pwd
    end
  end

  describe ".private_data_dir" do
    it "loads from the system dir" do
      setup_system_dir
      Config.private_data_dir.must_equal system_dir
    end
    it "loads from the local dir" do
      Config.private_data_dir.must_equal Pathname.pwd + ".data"
    end
  end

  describe ".database_dir" do
    it "loads from the system dir" do
      setup_system_dir
      Config.database_dir.must_equal system_dir + "database"
    end
    it "loads from the local dir" do
      Config.database_dir.must_equal Pathname.pwd + ".data" + "database"
    end
  end

  describe ".project" do
    it "returns a project" do
      Config.project.must_be_instance_of Config::Project
    end
  end

  describe ".project_loader" do
    it "returns a project loader" do
      Config.project_loader.must_be_instance_of Config::ProjectLoader
    end
  end

  describe ".private_data" do
    it "returns a private data" do
      Config.private_data.must_be_instance_of Config::PrivateData
    end
  end

  describe ".nodes" do
    it "returns nodes" do
      Config.nodes.must_be_instance_of Config::Nodes
    end
  end

  describe ".database" do
    it "returns a database" do
      Config.database.must_be_instance_of Config::Database
    end
  end

  describe ".default_remotes" do

    let(:remotes) { Config.default_remotes }

    before do
      setup_system_dir
    end

    specify "when nothing is in git" do
      remotes.project_git_config.url.must_equal  nil
      remotes.database_git_config.url.must_equal nil
    end

    specify "when the project is in git but the database is not" do
      (Config.project_dir + ".git").mkpath
      (Config.project_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      remotes.project_git_config.url.must_equal  'git@github.com:foo/bar.git'
      remotes.database_git_config.url.must_equal 'git@github.com:foo/bar-db.git'
    end

    specify "when the project is in git and the database is in git" do
      (Config.project_dir + ".git").mkpath
      (Config.project_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      (Config.database_dir + ".git").mkpath
      (Config.database_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar-database.git'
      end
      remotes.project_git_config.url.must_equal  'git@github.com:foo/bar.git'
      remotes.database_git_config.url.must_equal 'git@github.com:foo/bar-database.git'
    end
  end
end
