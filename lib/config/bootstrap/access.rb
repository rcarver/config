module Config
  module Bootstrap
    # Generates a script that gives root SSH access to the git repos.
    class Access < ::Config::Pattern

      desc "Path to write the configuration to"
      attr :path

      desc "Host of the git repo"
      key :ssh_host

      desc "Port to communicate on"
      attr :ssh_port, "22"

      desc "User with which to access the git repo"
      attr :ssh_user

      desc "The SSH keys used to authenticate. Hash of { name => content }"
      attr :ssh_keys

      def call
        file path do |f|
          f.template = "access.erb"
        end
      end

    end
  end
end

