module Config
  module CLI
    class StoreSecret < Config::CLI::Base

      desc <<-STR.dent
        Store a configuration secret for use by the hub to distribute to 
        new nodes.
      STR

      attr_accessor :secret_name

      attr_accessor :data

      def usage
        "#{name} [<name>]"
      end

      def parse(options, argv, env)
        @data = read_stdin
        @secret_name = argv.shift || "default"
      end

      def execute
        private_data.secret(secret_name).write(data)
      end

    end
  end
end

