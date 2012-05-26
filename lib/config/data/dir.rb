module Config
  module Data
    # Config::Data::Dir represents the `.data` directory that's
    # maintained by config.
    class Dir

      def initialize(dir)
        @dir = Pathname.new(dir)
      end

      # Get the FQN of the current node.
      #
      # Returns a String or nil.
      def fqn
        value = fqn_file.read
        value.chomp if value
      end

      # Set the FQN of the current node.
      #
      # fqn - String FQN.
      #
      # Returns nothing.
      def fqn=(fqn)
        fqn_file.write(fqn)
      end

      # Manage a secret.
      #
      # name - Symbol name of the secret.
      #
      # Returns a Config::Data::File.
      def secret(name)
        Config::Data::File.new(@dir + "secret-#{name}")
      end

      # Manage an SSH private key.
      #
      # name - Symbol name of the key.
      #
      # Returns a Config::Data::File.
      def ssh_key(name)
        Config::Data::File.new(@dir + "ssh-key-#{name}")
      end

      # Manage the signature for an SSH known host.
      #
      # host - String name of the host.
      #
      # Returns a Config::Data::File.
      def ssh_host_signature(host)
        Config::Data::File.new(@dir + "ssh-host-#{host}")
      end

      # Get a database that manages information about your nodes.
      #
      # Returns a Config::Data::Database.
      def database
        Config::Data::GitDatabase.new(repo.path, repo)
      end

      # Get the stored accumulation.
      #
      # Returns a Config::Core::Accumulation or nil.
      def accumulation
        data = accumulation_file.read
        Config::Core::Accumulation.from_string(data) if data
      end

      # Store the accumulation.
      #
      # accumulation - Config::Core::Accumulation.
      #
      # Returns nothing.
      def accumulation=(accumulation)
        accumulation_file.write(accumulation.serialize)
      end

      # Get the path at which the git database lives.
      #
      # Returns a String.
      def repo_path
        (@dir + "project-data").to_s
      end

    protected

      def accumulation_file
        Config::Data::File.new(@dir + "accumulation.marshall")
      end

      def fqn_file
        Config::Data::File.new(@dir + "fqn")
      end

      def repo
        Config::Core::GitRepo.new(repo_path)
      end

    end
  end
end
