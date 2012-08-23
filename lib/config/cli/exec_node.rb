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
        # Get the most appropriate settings. Since this command is now the node
        # gets created, it is very likely that it doesn't yet exist.
        if project.node?(@fqn)
          settings = project.node_settings(@fqn)
        else
          settings = project.base_settings
        end

        # Query the state of the node and store it in the database. This
        # creates or updates the node.
        nodes.update_node(@fqn, settings.fact_finder.call)

        # Execute the node by performing the instructions described by its
        # blueprint.
        project_loader.require_all # require all so that the marshal'd accumulation can load.
        marshaled_accumulation = private_data.accumulation
        private_data.accumulation = project.execute_node(@fqn, marshaled_accumulation)
      end

    end
  end
end


