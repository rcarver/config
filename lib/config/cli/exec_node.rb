module Config
  module CLI
    class ExecNode < Config::CLI::Base

      attr_accessor :fqn

      def usage
        "#{name} [<fqn>]"
      end

      def parse(options, argv, env)
        @fqn = argv.shift || data_dir.fqn
        @fqn or abort usage
      end

      def execute
        project.update_node(@fqn)
        project.require_all
        data_dir.accumulation = project.execute_node(@fqn, data_dir.accumulation)
      end

    end
  end
end


