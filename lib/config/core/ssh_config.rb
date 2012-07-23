module Config
  module Core
    class SSHConfig

      # Get/Set the Host. This can be anything to identiy an ssh server
      # by. Use the hostname to set the actual host.
      attr_accessor :host

      # Get/Set the User to ssh as.
      attr_accessor :user

      # Set the name to the SSH key to use when connecting.
      attr_writer :ssh_key

      # Get the name to the SSH key to use when connecting.
      def ssh_key
        @ssh_key || "default"
      end

      # Set the Port to connect to.
      attr_writer :port

      # Get the Port (defaults to 22).
      def port
        @port || 22
      end

      # Set the hostname to connect to.
      attr_writer :hostname

      # Get the Hostname (defaults to host).
      def hostname
        @hostname || host
      end

      # Get the extra ssh config options.
      #
      # Returns an Array that may be appended to.
      def extras
        @extras ||= []
      end

      # Generate a 'Host' stanza for an .ssh/config file.
      #
      # private_data - Config::PrivateData to retrieve named SSH key.
      #
      # Returns a String.
      def to_host_config(private_data)
        <<-STR
Host #{host}
  Port #{port}
  Hostname #{hostname}
  User #{user}
  IdentityFile #{private_data.ssh_key(ssh_key).path}
  #{extras.join("\n")}
        STR
      end

    end
  end
end
