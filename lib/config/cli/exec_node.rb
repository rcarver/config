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
        project.update_node(@fqn)
        project_data.accumulation = project.execute_node(@fqn, project_data.accumulation)
      end

    end
  end
end


