module Config
  module CLI
    class KnowHosts < Config::CLI::Base

      desc <<-STR.dent
        Generate and store hostname signatures for each host that will be
        accessed during project execution.
      STR

      attr_accessor :hosts

      def usage
        "#{name} <host>"
      end

      def parse(options, argv, env)
        @hosts = argv.any? ? argv : project.base_settings.remotes.ssh_hostnames
      end

      def execute
        @hosts.each do |host|
          stderr.puts "Generating signature for #{host.inspect}"
          capture3("ssh-keyscan -H #{host}") do |out, err, status|
            private_data.ssh_host_signature(host).write(out)
          end
        end
      end

    end
  end
end
