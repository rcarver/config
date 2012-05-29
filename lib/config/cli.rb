require 'config'
require 'optparse'

module Config
  module CLI

    def self.run
      Config.log_to STDOUT
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

    config "know-hosts", :KnowHosts

    class Base

      def initialize(name, stdin, stdout, stderr)
        @name = name
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr
      end

      attr :name
      attr :stdin
      attr :stdout
      attr :stderr

      def run(argv, env)
        parse!(argv, env)
        execute
      end

      def parse!(argv=[], env={})
        options = parse_options!(argv)
        parse(options, argv, env)
      end

      def options(opts)
        # noop
      end

      def parse(options, argv, env)
        # noop
      end

      def execute
        # noop
      end

      def usage
        name
      end

      def parse_options!(argv)
        options = OptionParser.new { |opts|
          opts.banner = "usage: #{usage}"
          options(opts)
          opts.on_tail("-h", "--help") do
            abort opts.to_s
          end
        }
        options.parse!
        options
      end

      # Returns a Config::Project.
      def project
        @project ||= Config.project
      end
      attr_writer :project

      # Returns a Config::Data::Dir.
      def data_dir
        @data_dir ||= project.data_dir
      end
      attr_writer :data_dir

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

      # Set the shell exit status and quit.
      def exit(status)
        kernel.exit(status)
      end

      # Write a message to stderr and quit with non-zero status.
      def abort(*args)
        kernel.abort(*args)
      end

      # Run a system command.
      #
      # Returns [String (stdout), String (stderr), Integer (status)].
      def capture3(command)
        out, err, status = open3.capture3(command)

        if status.exitstatus != 0
          stderr.puts "An error occurred (#{status.exitstatus.inspect}) while running `#{command}`"
          stderr.puts out unless out.empty?
          stderr.puts err unless err.empty?
          exit status.exitstatus
        end

        return out, err, status.exitstatus
      end

    end
  end
end
