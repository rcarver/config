require 'fileutils'

module Config
  module Patterns
    class Directory
      include Config::Changable

      attr :path
      attr :owner
      attr :group
      attr :mode
      attr :touch

      def call
        # noop
      end

      def to_s
        "Directory #{@path}"
      end

      def create
        unless File.exist?(@path)
          FileUtils.mkdir_p(@path)
          changed! "created"
        end

        stat = Config::Core::Stat.new(self, @path)
        stat.owner = owner if owner
        stat.group = group if group
        stat.mode = mode if mode
        stat.touch if touch
      end

      def destroy
        if File.exist?(path)
          File.rm_rf(path)
          changed! "destroyed"
        end
      end

    end
  end
end
