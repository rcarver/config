module Config
  module CLI
    class ExecNode < Config::CLI::Base

      desc <<-STR.dent
        Execute the project. Running this command will update the database for
        the given node and then execute the node's blueprint.
      STR

      attr_accessor :fqn

      def usage
        "#{name} <fqn>"
      end

      def parse(options, argv, env)
        @fqn = argv.shift or abort usage
      end

      def execute
        project_loader.require_all # require all so that the marshall'd accumulation can load.
        project.update_node(@fqn)
        private_data.accumulation = project.execute_node(@fqn, private_data.accumulation)
      end

    end
  end
end


