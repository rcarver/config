require 'tempfile'

module Config
  module CLI
    class CreateBootstrap < Config::CLI::Base

      desc <<-STR
Generate a bootstrap script and write it to STDOUT. The script can be
run on a remote server in order to initialize it as a node.
      STR

      attr_accessor :cluster_name
      attr_accessor :blueprint_name
      attr_accessor :identity
      attr_accessor :log

      def config_log_stream
        stderr
      end

      def usage
        "#{name} <cluster> <blueprint> <identity>"
      end

      def add_options(opts)
        @log = false
        opts.on("--log", "Log bootstrap results instead of writing to STDOUT/STDERR") do
          @log = true
        end
      end

      def parse(options, argv, env)
        @cluster_name   = argv.shift or abort usage
        @blueprint_name = argv.shift or abort usage
        @identity       = argv.shift or abort usage
      end

      def execute

        unless project.cluster?(cluster_name)
          abort "unknown cluster #{cluster_name.inspect}"
        end

        unless project.blueprint?(blueprint_name)
          abort "unknown blueprint #{blueprint_name.inspect}"
        end

        identity_file = Tempfile.new("identity")
        system_file = Tempfile.new("system")
        access_file = Tempfile.new("access")
        project_file = Tempfile.new("project")

        # Configure data storage on the node.
        remote_project_data = Config::ProjectData.new(Config.system_dir)

        # Configure remotes for the node.
        remotes = project.remotes_for(cluster_name)

        # Local variables for `blueprint` block scope.
        cluster_name = @cluster_name
        blueprint_name = @blueprint_name
        identity = @identity
        project = self.project
        project_data = self.project_data

        blueprint do

          # Install system dependencies.
          add Config::Bootstrap::System do |p|
            p.path = system_file
            # TODO: set ruby,bundler,git versions
          end

          # Establish the identity of the server.
          add Config::Bootstrap::Identity do |p|
            p.path = identity_file
            p.cluster = cluster_name
            p.blueprint = blueprint_name
            p.identity = identity
            # TODO: allow the dns_domain_name to be configured per cluster.
            p.dns_domain_name = project_data.domain(:default).read
            # TODO: allow secret to be configured per cluster.
            p.secret = project_data.secret(:default).read
          end

          # Provide access to the git repos.
          add Config::Bootstrap::Access do |p|
            p.path = access_file
            p.ssh_configs = remotes.ssh_configs.map do |c|
              c.to_host_config(remote_project_data)
            end
            p.ssh_keys = begin
              keys = {}
              remotes.ssh_configs.each do |c|
                file = remote_project_data.ssh_key(c.ssh_key).path
                # TODO: handle the ssh key is missing locally.
                key = project_data.ssh_key(c.ssh_key).read
                keys[file] = key
              end
              keys
            end
            p.ssh_known_hosts = begin
              hosts = {}
              remotes.ssh_hostnames.each do |host|
                # TODO: handle the host is missing locally.
                hosts[host] = project_data.ssh_host_signature(host).read
              end
              hosts
            end
          end

          # Initialize and run the project.
          add Config::Bootstrap::Project do |p|
            p.path = project_file
            p.git_uri = remotes.project_git_config.url
            p.update_project_script = project.update_project_script
          end
        end

        # Log the bootstrap process.
        stdout.puts "exec &> /var/log/config-bootstrap.log" if @log

        # Abort on any error.
        stdout.puts "set -e"

        # Show each command that's run.
        # TODO: only enable -x if a debug option is set?
        stdout.puts "set -x"

        stdout.puts
        stdout.puts "echo; echo '[System]'"
        stdout.puts system_file.read
        stdout.puts
        stdout.puts "echo; echo '[Identity]'"
        stdout.puts identity_file.read
        stdout.puts
        stdout.puts "echo; echo '[Access]'"
        stdout.puts access_file.read
        stdout.puts
        stdout.puts "echo; echo '[Project]'"
        stdout.puts project_file.read

        system_file.close!
        identity_file.close!
        access_file.close!
        project_file.close!
      end

    end
  end
end


