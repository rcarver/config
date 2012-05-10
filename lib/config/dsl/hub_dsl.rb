module Config
  module DSL
    # Syntax for Hub files, stored at hub.rb.
    class HubDSL

      def initialize
        @data = {}
      end

      # Public: Set the project repository.
      #
      # repo - String URI of your project repo.
      #
      # Returns nothing.
      def git_project(repo)
        @data[:git_project] = repo
      end

      # Public: Set the data repository.
      #
      # repo - String URI of your data repo.
      #
      def git_data(repo)
        @data[:git_data] = repo
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
    end
  end
end

