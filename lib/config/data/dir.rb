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
      # Returns a Config::DataSecret.
      def secret(name)
        Config::Data::Secret.new(@dir + "secret-#{name}")
      end

      # Get a database that manages information about your nodes.
      #
      # Returns a Config::Data::Database.
      def database
        Config::Data::GitDatabase.new(repo.path, repo)
      end

      # Get the git repository that stores node data.
      #
      # Returns a Config::Data::Repo.
      def repo
        Config::Data::Repo.new(@dir + "project-data")
      end

    end
  end
end
