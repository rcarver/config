require 'config'
require 'optparse'
require 'ostruct'
require 'open3'

module Config
  module CLI

    def self.exec
      cli = self.new(File.basename($0), STDIN, STDOUT, STDERR)
      cli.run(ARGV, ENV)
    end

    def self.new(name, stdin, stdout, stderr)
      klass_name = binaries[name] or abort "Unknown config script #{name.inspect}"
      klass = const_get(klass_name)
      klass.new(name, stdin, stdout, stderr)
    end

    def self.config(name, klass = nil)
      autoload klass, "config/cli/#{name.gsub('-', '_')}"
      binaries["config-#{name}"] = klass
    end

    def self.binaries
      @binaries ||= {}
    end

    config "create-blueprint", :CreateBlueprint
    config "create-bootstrap", :CreateBootstrap
    config "create-cluster", :CreateCluster
    config "create-pattern", :CreatePattern
    config "create-topic", :CreateTopic
    config "exec-node", :ExecNode
    config "init-project", :InitProject
    config "know-hosts", :KnowHosts
    config "show-node", :ShowNode
    config "store-secret", :StoreSecret
    config "store-ssh-key", :StoreSSHKey
    config "try-blueprint", :TryBlueprint
    config "update-database", :UpdateDatabase
    config "update-project", :UpdateProject

    class Base

      def self.desc(desc=nil)
        @desc = desc if desc
        @desc
      end

      def initialize(name, stdin, stdout, stderr)
        @name = name
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr
        @options = OpenStruct.new
      end

      attr :name
      attr :stdin
      attr :stdout
      attr :stderr
      attr :options

      attr_writer :options

      # Instantiate another CLI command. The sub-command will be initialized
      # with the same input/output streams as the current command.
      #
      # name - String the name of the command.
      #
      # Returns a Config::CLI::Base.
      # Raises ArgumentError if the name is unknown.
      def cli(name)
        subcommand_builder.call(name)
      end

      def run(argv, env)
        parse!(argv, env)
        Config.log_to(config_log_stream || StringIO.new)
        execute
      end

      def parse!(argv=[], env={})
        opts = parse_options!(argv)
        parse(opts, argv, env)
      end

      def add_options(opts)
        # noop
      end

      def parse(opts, argv, env)
        # noop
      end

      def execute
        # noop
      end

      def usage
        name
      end

      # Specify where config should log. Override this method to change it.
      # Return nil to disable Config's logging.
      def config_log_stream
        stdout
      end

      def read_stdin
        if stdin.tty?
          abort "Expected data on STDIN. #{usage}"
        else
          stdin.read
        end
      end

      def parse_options!(argv)
        opts = OptionParser.new { |opts|
          opts.banner = "Usage: #{usage}"
          if self.class.desc
            opts.banner << "\n\n#{self.class.desc}\n"
          end
          add_options(opts)
          opts.on_tail("-n", "--noop", "Don't actually execute anything") do
            noop!
          end
          opts.on_tail("-v", "--version", "Show the version of Config") do
            puts Config::VERSION
            exit(0)
          end
          opts.on_tail("-h", "--help", "Show this help") do
            abort opts.to_s
          end
        }
        opts.parse!(argv)
        opts
      end

      # Set noop mode on the program. In noop mode, no changes should occur on
      # the filesystem.
      def noop!
        options.noop = true
      end

      # Check for noop mode on the program.
      def noop?
        options.noop
      end

      # Returns a Proc. That proc takes a name and returns a ClI::Base.
      def subcommand_builder
        @subcommand_builder || lambda { |name|
          cli = Config::CLI.new("config-#{name}", stdin, stdout, stderr)
          cli.options = options
          cli
        }
      end
      attr_writer :subcommand_builder

      # Returns a Config::Project.
      def project
        @project ||= Config.project
      end
      attr_writer :project

      # Returns a Config::ProjectLoader.
      # DEPRECATED
      def project_loader
        @project_loader ||= Config.project_loader
      end
      attr_writer :project_loader

      # Returns a Config::PrivateData.
      def project_data
        @project_data ||= Config.project_data
      end
      attr_writer :project_data

      # Returns a Kernel.
      def kernel
        @kernel ||= Kernel
      end
      attr_writer :kernel

      # Returns an Open3>
      def open3
        @open3 ||= Open3
      end
      attr_writer :open3

      # Replace the current process.
      def exec(code)
        kernel.exec(code)
      end

      # Set the shell exit status and quit.
      def exit(status)
        kernel.exit(status)
      end

      # Write a message to stderr and quit with non-zero status.
      def abort(*args)
        kernel.abort(*args)
      end

      # Execute a blueprint.
      def blueprint(&block)
        blueprint = Config::Blueprint.new(name, &block)
        @accumulations ||= []
        @accumulations << blueprint.accumulate
        blueprint.noop! if options.noop
        blueprint.execute
      end

      # Test: Get the patterns that were executed as part of the blueprint.
      #
      # klass - Class of the pattern.
      #
      # Returns an Array of Config::Pattern.
      def find_blueprints(klass)
        (@accumulations || []).map { |a| a.find_all { |p| klass === p } }.flatten
      end

      # Run a system command.
      #
      # Yields [String (stdout), String (stderr), Integer (status)].
      #
      # Returns nothing.
      def capture3(command)

        if noop? && Open3 == open3
          # Print the command and don't yield.
          stdout.puts "+ #{command}"
          return
        end

        out, err, status = open3.capture3(command)

        if status.exitstatus != 0
          stderr.puts "An error occurred (#{status.exitstatus.inspect}) while running `#{command}`"
          stderr.puts out unless out.empty?
          stderr.puts err unless err.empty?
          exit status.exitstatus
        end

        yield out, err, status.exitstatus

        return
      end

    end
  end
end
