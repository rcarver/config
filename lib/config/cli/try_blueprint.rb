module Config
  module CLI
    class TryBlueprint < Config::CLI::Base

      attr_accessor :blueprint_name

      attr_accessor :cluster_name

      def usage
        "#{name} <blueprint> [<cluster>]"
      end

      def parse(options, argv, env)
        @blueprint_name = argv.shift or abort usage
        @cluster_name = argv.shift
      end

      def execute
        project.try_blueprint(blueprint_name, cluster_name)
      end

    end
  end
end



