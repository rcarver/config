module Config
  module CLI
    class CreateBlueprint < Config::CLI::Base

      attr_accessor :blueprint_names

      def usage
        "#{name} <name>..."
      end

      def parse(options, argv, env)
        abort usage if argv.empty?
        @blueprint_names = argv
      end

      def execute
        blueprint_names = @blueprint_names
        blueprint do
          blueprint_names.each do |name|
            add Config::Meta::Blueprint do |p|
              p.root = File.expand_path(".")
              p.name = name
            end
          end
        end
      end

    end
  end
end
