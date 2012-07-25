module Config
  module Core
    class GitConfig < Config::Core::SSHConfig

      # Get/Set the git clone path.
      attr_accessor :path

      # Set the full git clone url.
      attr_writer :url

      # Get the full git clone url.
      def url
        @url || case
        when user && host && path
          "#{user}@#{host}:#{path}"
        when host && path
          "#{host}:#{path}"
        end
      end

      def host
        @host || host_from_url
      end

      def user
        @user || user_from_url
      end

    protected

      def host_from_url
        @url[/@(.*?):/, 1] || @url[/(.*?):/, 1] if @url
      end

      def user_from_url
        @url[/(^.*)@/, 1] if @url
      end

    end
  end
end

