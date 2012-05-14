module Config
  module Data
    # Config::Data::Dir represents the `.data` directory that's
    # maintained by config.
    class Dir

      def initialize(dir)
        @dir = Pathname.new(dir)
      end

      # Manage a secret.
      #
      # name - Symbol name of the secret.
      #
      # Returns a Config::Data::File.
      def secret(name)
        Config::Data::File.new(@dir + "secret-#{name}")
      end

      # Manage the SSH private key used to access git repos.
      #
      # Returns a Config::Data::File.
      def git_ssh_key
        Config::Data::File.new(@dir + "ssh-key")
      end

      # Get a database that manages information about your nodes.
      #
      # Returns a Config::Data::Database.
      def database
        Config::Data::GitDatabase.new(repo.path, repo)
      end

      # Get the path at which the git database lives.
      #
      # Returns a String.
      def repo_path
        (@dir + "project-data").to_s
      end

    protected

      def repo
        Config::Data::Repo.new(repo_path)
      end

    end
  end
end
