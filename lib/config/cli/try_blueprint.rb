module Config
  module CLI
    class TryBlueprint < Config::CLI::Base

      desc <<-STR
Execute a blueprint in order to inspect what it does. The execution will
not touch the filesystem or otherwise manipulate the machine that
executes this command. Specifying a cluster will use and validate that
the cluster provides all required variables. Otherwise, the variables
used during execution will be collected and reported.
      STR

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



