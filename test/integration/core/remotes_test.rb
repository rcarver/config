require 'helper'

describe "filesystem", Config::Core::Remotes do

  describe ".default" do

    # It would be cool if Pathname implemented #chdir.
    # But it doesn't. So we do this.
    let(:chdir) do
      Class.new do
        def initialize(dir)
          @dir = dir
        end
        def chdir(&block)
          ::Dir.chdir(@dir, &block) if @dir.exist?
        end
      end
    end

    let(:project_dir)  { tmpdir + "project" }
    let(:database_dir) { tmpdir + "database" }

    let(:remotes) do
      Config::Core::Remotes.default(chdir.new(project_dir), chdir.new(database_dir))
    end

    specify "when nothing is in git" do
      remotes.project_git_config.url.must_equal  nil
      remotes.database_git_config.url.must_equal nil
    end

    specify "when the project is in git but the database is not" do
      (project_dir + ".git").mkpath
      (project_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      remotes.project_git_config.url.must_equal  'git@github.com:foo/bar.git'
      remotes.database_git_config.url.must_equal 'git@github.com:foo/bar-db.git'
    end

    specify "when the project is in git and the database is in git" do
      (project_dir + ".git").mkpath
      (project_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar.git'
      end
      (database_dir + ".git").mkpath
      (database_dir + ".git/config").open("w") do |f|
        f.puts '[remote "origin"]'
        f.puts '        url = git@github.com:foo/bar-database.git'
      end
      remotes.project_git_config.url.must_equal  'git@github.com:foo/bar.git'
      remotes.database_git_config.url.must_equal 'git@github.com:foo/bar-database.git'
    end
  end
end
