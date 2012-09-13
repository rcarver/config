require 'fileutils'

module Config
  module Patterns
    class Chmod < Config::Pattern

      desc "Path to the file or directory to modify"
      key :path

      desc "Permissions in octal"
      attr :mode

      desc "Apply changes recursively"
      attr :recursive, false

      def describe
        recurse = "(recursively)" if recursive
        ["Chmod", path, "to", mode_string, recurse].compact.join(" ")
      end

      def create
        stat_mode = ::File.stat(path).mode & 07777

        unless stat_mode == mode_octal
          if recursive
            fu.chmod_R(mode_octal, path)
          else
            fu.chmod(mode_octal, path)
          end
          changes << "set mode"
          log << log.colorize("Set mode to #{mode_string}", :brown)
        end
      end

      def mode_octal
        mode.respond_to?(:oct) ? mode.oct : mode
      end

      def mode_string
        if m = mode_octal
          str = m.to_s(8)
          str = "0" + str if str.size == 3
          str
        end
      end

      # Dependency injection for testing.
      attr_writer :fu

    protected

      def fu
        @fu ||= ::FileUtils
      end

    end
  end
end
