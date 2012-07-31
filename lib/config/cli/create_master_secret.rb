module Config
  module CLI
    class CreateMasterSecret < Config::CLI::Base

      desc <<-STR
Generate a master secret and store it in your private data.
      STR

      def usage
        "#{name}"
      end

      def parse(options, argv, env)
        # TODO: allow configuration of the generator
        @secrets_generator = Config::Secrets::Generator.new
      end

      def execute
        # TODO: Use a better method to generate the master key.
        password = (rand * 1000).to_s
        salt = (rand * 1000).to_s
        key = @secrets_generator.generate_key(password, salt)
        private_data.secret("master").write(key)
      end

    end
  end
end


