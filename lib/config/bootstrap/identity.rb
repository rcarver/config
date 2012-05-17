module Config
  module Bootstrap
    # Generates a script to establish the server's identity. To set
    # identity we set the hostname and store a secret.
    class Identity < ::Config::Pattern

      desc "Path to write the configuration to"
      attr :path

      desc "The name of the blueprint"
      key :blueprint

      desc "The name of the cluster"
      key :cluster

      desc "A unique id for the node"
      key :identity

      desc "The secret"
      attr :secret

      def call
        file path do |f|
          f.template = "identity.erb"
        end
      end

    protected

      def fqn
        Config::Node.new(cluster, blueprint, identity).fqn
      end

    end
  end
end
