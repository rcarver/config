module Config
  module Core
    class GitConfig < Config::Core::SSHConfig

      # Get/Set the git clone url.
      attr_accessor :url

      def host
        @host || host_from_url
      end

      def user
        @user || user_from_url
      end

    protected

      def host_from_url
        url[/@(.*?):/, 1] || url[/(.*?):/, 1] if url
      end

      def user_from_url
        url[/(^.*)@/, 1] if url
      end

    end
  end
end

