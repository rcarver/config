module Config
  module CLI
    class KnowHosts < Config::CLI::Base

      attr_accessor :hosts

      def usage
        "#{name} [HOST]"
      end

      def parse(options, argv, env)
        @hosts = argv.any? ? argv : project.ssh_hosts
      end

      def execute
        @hosts.each do |host|
          stderr.puts "Generating signature for #{host.inspect}"
          signature, err, status = capture3("ssh-keyscan -H #{host}")
          data_dir.ssh_host_signature(host).write(signature)
        end
      end

    end
  end
end
