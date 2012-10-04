module Config
  module CLI
    class Encrypt < Config::CLI::Base

      desc <<-STR
Encrypt sensitive information so that it can be stored in the project.
      STR

      def usage
        "#{name} [options] <name:secret...>"
      end

      def add_options(opts)
        opts.on("-c", "--cluster NAME", "The cluster to encrypt for") do |cluster_name|
          settings = project.cluster_settings(cluster_name)
          @generator = settings.secrets_generator
        end
        opts.on("-f", "--file", "Store the secret in a file (implies --syntax)") do
          @output_file = true
        end
      end

      def parse(options, argv, env)
        @generator ||= project.base_settings.secrets_generator
        @values = argv
      end

      def execute
        cipher = Config.cipher(@generator)
        @values.each do |key_value|
          key, value = key_value.split(':')
          secret = cipher.encrypt(value)
          if @output_file
            project.secrets(key).write(value)
          end
          @stdout.print %[#{key}: secret("#{secret}")]
          @stderr.print "\n"
        end
      end

    end
  end
end



