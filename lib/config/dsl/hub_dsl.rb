module Config
  module DSL
    # Syntax for Hub files, stored at hub.rb.
    class HubDSL

      def initialize
        @data = {
          project_config: Config::Core::GitConfig.new,
          data_config: Config::Core::GitConfig.new,
          ssh_configs: []
        }
      end

      class RepoDSL

        attr_writer :url
        attr_writer :ssh_key
        attr_writer :hostname
        attr_writer :user
        attr_writer :port

        def to_git_config
          Config::Core::GitConfig.new.tap do |c|
            c.url = @url if @url
            c.ssh_key = @ssh_key if @ssh_key
            c.ssh_config.hostname = @hostname if @hostname
            c.ssh_config.user = @user if @user
            c.ssh_config.port = @port if @port
          end
        end

        def to_s
          "<Repo>"
        end

        def inspect
          "<Repo>"
        end
      end

      # Public: Configure the project repo.
      #
      # url - String url of your project repo
      #
      # Yields a Config::DSL::HubDSL::RepoDSL.
      #
      # Returns nothing.
      def project_repo(url=nil, &block)
        config = git_config(url, &block)
        @data[:project_config] = config
        @data[:ssh_configs] << config.ssh_config
      end

      # Public: Configure the data repo.
      #
      # url - String url of your data repo.
      # 
      # Yields a Config::DSL::HubDSL::RepoDSL.
      #
      # Returns nothing.
      def data_repo(url=nil, &block)
        config = git_config(url, &block)
        @data[:data_config] = config
        @data[:ssh_configs] << config.ssh_config
      end

      # Public: Add additional ssh configuration.
      #
      # Yields a Config::DSL::HubDSL::RepoDSL.
      # 
      # Returns nothing.
      def ssh_config(&block)
        config = git_config(nil, &block)
        @data[:ssh_configs] << config.ssh_config
      end

      def to_s
        "<Hub>"
      end

      def inspect
        "<Hub>"
      end

      def [](key)
        @data[key]
      end

    protected

      def git_config(url, &block)
        if url && block_given?
          raise ArgumentError, "Specify either the url or a block"
        end
        repo = RepoDSL.new
        repo.url = url
        yield repo if block_given?
        repo.to_git_config
      end

    end
  end
end

