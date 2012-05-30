module Config
  module CLI
    class StoreSSHKey < Config::CLI::Base

      attr_accessor :ssh_key_name

      attr_accessor :data

      def usage
        "#{name} [<name>]"
      end

      def parse(options, argv, env)
        @data = read_stdin
        @ssh_key_name = argv.shift || "default"
      end

      def execute
        data_dir.ssh_key(ssh_key_name).write(data)
      end

    end
  end
end

