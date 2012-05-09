module Config
  module Bootstrap
    # Generates a script to boostrap the system dependencies.
    class System < ::Config::Pattern

      desc "Path to write the configuration to"
      attr :path

      desc "The version of Ruby to install"
      attr :ruby_version, "1.9.3-p194"

      desc "The version of RubyGems to install"
      attr :rubygems_version, "1.8.24"

      desc "The version of Bundler to install"
      attr :bundler_version, "1.1.0"

      desc "The version of Git to install"
      attr :git_version, "1.7.10.1"

      def call
        file path do |f|
          f.template = "system.erb"
        end
      end

    protected

      def apt_git_version
        "1:#{git_version}-1ubuntu0.2"
      end

    end
  end
end

