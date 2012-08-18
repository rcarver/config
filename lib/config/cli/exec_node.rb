module Config
  module CLI
    class ExecNode < Config::CLI::Base

      desc <<-STR
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
        settings = project.node_settings(@fqn)
        nodes.update_node(@fqn, settings.fact_finder.call)

        project_loader.require_all # require all so that the marshal'd accumulation can load.
        marshaled_accumulation = private_data.accumulation
        private_data.accumulation = project.execute_node(@fqn, marshaled_accumulation)
      end

    end
  end
end


