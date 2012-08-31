require 'fileutils'

module Config
  module Core
    # This class describes the various directories that config uses.
    class Directories

      # Initialize a new Directories.
      #
      # system_dir  - String path to the system-installed project
      #               (typically /etc/config).
      # current_dir - String path to the current working directory.
      #
      def initialize(system_dir, current_dir)
        @system_dir = Pathname.new(system_dir)
        @current_dir = Pathname.new(current_dir)
      end

      # The directory where the current project lives.
      #
      # Returns a Pathname.
      def project_dir
        if @system_dir.exist?
          @system_dir + "project"
        else
          @current_dir
        end
      end

      # The directory where the current private data lives.
      #
      # Returns a Pathname.
      def private_data_dir
        if @system_dir.exist?
          @system_dir
        else
          @current_dir + ".data"
        end
      end

      # The directory where the database lives.
      #
      # Returns a Pathname.
      def database_dir
        if @system_dir.exist?
          @system_dir + "database"
        else
          private_data_dir + "database"
        end
      end

      # The directory from which blueprints are executed.
      #
      # Returns a Pathname.
      def run_dir
        if @system_dir.exist?
          @system_dir + "run"
        else
          @current_dir
        end
      end

      # Create the run directory or recreate it if it exists. After this
      # method the run directory will exist and be empty. Only operates
      # on a system-level run directory.
      #
      # Returns nothing.
      def create_run_dir!
        if @system_dir.exist?
          ::FileUtils.rm_rf(run_dir) if ::File.exist?(run_dir)
          ::FileUtils.mkdir_p(run_dir)
        end
      end
    end
  end
end
