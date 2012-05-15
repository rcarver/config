module Config
  module Core
    class GitConfig

      def initialize
        @ssh_key = "default"
      end

      # Get/Set the git clone url.
      attr_accessor :url

      # Get/Set the name of the SSH Key.
      attr_accessor :ssh_key

      # Get the ssh configuration. The config assumes its default from
      # the url. The object returned is the same instance on each
      # invocation so that you may adjust the config and store it along
      # with this object.
      #
      # Returns a Config::Core::SSHConfig.
      def ssh_config
        @ssh_config ||= Config::Core::SSHConfig.new.tap do |c|
          c.host = host
          c.user = user
          c.ssh_key = ssh_key
        end
      end

      def host
        url[/@(.*?):/, 1] || url[/(.*?):/, 1] if url
      end

      def user
        url[/(^.*)@/, 1] if url
      end

    end
  end
end

