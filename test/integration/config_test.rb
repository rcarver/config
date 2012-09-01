require 'helper'

describe "filesystem", Config do

  describe ".directories" do
    it "returns a directories" do
      Config.directories.must_be_instance_of Config::Core::Directories
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

    let(:system_dir) { tmpdir + "system" }
    let(:current_dir) { tmpdir + "current" }

    let(:dirs) { Config::Core::Directories.new(system_dir, current_dir) }

    before do
      current_dir.mkdir
      Config.directories = dirs
    end

    let(:remotes) { Config.default_remotes }

    specify "when nothing is in git" do
      remotes.project_git_config.url.must_equal  nil
      remotes.database_git_config.url.must_equal nil
    end

    specify "when the project is in git but the database is not" do
      (dirs.project_dir + ".git").mkpath
      (dirs.project_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      remotes.project_git_config.url.must_equal  'git@github.com:foo/bar.git'
      remotes.database_git_config.url.must_equal 'git@github.com:foo/bar-db.git'
    end

    specify "when the project is in git and the database is in git" do
      (dirs.project_dir + ".git").mkpath
      (dirs.project_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      (dirs.database_dir + ".git").mkpath
      (dirs.database_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar-database.git'
      end
      remotes.project_git_config.url.must_equal  'git@github.com:foo/bar.git'
      remotes.database_git_config.url.must_equal 'git@github.com:foo/bar-database.git'
    end
  end
end
