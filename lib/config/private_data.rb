module Config
  # This class manages everything that's not checked into the project
  # repository.
  class PrivateData

    def initialize(path)
      @path = Pathname.new(path)
    end

    # Internal.
    attr_reader :path

    # Internal.
    def chdir(&block)
      Dir.chdir(@path, &block) if @path.exist?
    end

    # Manage a secret.
    #
    # name - Symbol name of the secret.
    #
    # Returns a Config::Core::File.
    def secret(name)
      Config::Core::File.new(@path + "secret-#{name}")
    end

    # Manage an SSH private key.
    #
    # name - Symbol name of the key.
    #
    # Returns a Config::Core::File.
    def ssh_key(name)
      Config::Core::File.new(@path + "ssh-key-#{name}")
    end

    # Manage the signature for an SSH known host.
    #
    # host - String name of the host.
    #
    # Returns a Config::Core::File.
    def ssh_host_signature(host)
      Config::Core::File.new(@path + "ssh-host-#{host}")
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

  protected

    def accumulation_file
      Config::Core::File.new(@path + "accumulation.marshall")
    end

  end
end
