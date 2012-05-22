module Config
  module Bootstrap
    # Generates a script that gives root SSH access to the git repos.
    class Access < ::Config::Pattern

      desc "Path to write the configuration to"
      attr :path

      desc "Array of configuration blocks to write to .ssh/config"
      attr :ssh_configs

      desc "Array of SSH keys to install. Hash of { name: content }"
      attr :ssh_keys

      desc "Array of SSH known hosts. Hash of { host: signature }"
      attr :ssh_known_hosts

      def call
        file path do |f|
          f.template = "access.erb"
        end
      end

    end
  end
end

