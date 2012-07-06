module Config
  # This class manages everything that's not checked into the project
  # repository.
  class ProjectData

    def initialize(path)
      @path = Pathname.new(path)
    end

    attr_reader :path

    # Manage a secret.
    #
    # name - Symbol name of the secret.
    #
    # Returns a Config::Data::File.
    def secret(name)
      Config::Data::File.new(@path + "secret-#{name}")
    end

    # Manage an SSH private key.
    #
    # name - Symbol name of the key.
    #
    # Returns a Config::Data::File.
    def ssh_key(name)
      Config::Data::File.new(@path + "ssh-key-#{name}")
    end

    # Manage the signature for an SSH known host.
    #
    # host - String name of the host.
    #
    # Returns a Config::Data::File.
    def ssh_host_signature(host)
      Config::Data::File.new(@path + "ssh-host-#{host}")
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
      (@path + "project-data").to_s
    end

    def database
      Config::Data::GitDatabase.new(repo.path, repo)
    end

    # Update the database.
    #
    # Returns nothing.
    #def update_database
      #database.update
    #end

    def remotes(name)
      Config::Data::Remotes.new(@path + "remotes-#{name}.yml")
    end

    # Get all of the SSH host names that are used during execution.
    #
    # Returns an Array of String.
    #def ssh_hostnames
      #remotes.ssh_hostnames
    #end

  protected

    def accumulation_file
      Config::Data::File.new(@path + "accumulation.marshall")
    end

    def repo
      Config::Core::GitRepo.new(repo_path)
    end

  end
end
