module Config
  module CLI
    class ShowNode < Config::CLI::Base

      attr_accessor :fqn

      attr_accessor :path

      def config_log_stream
        nil
      end

      def usage
        "#{name} <fqn> [<json path>]"
      end

      def parse(options, argv, env)
        @fqn = argv.shift or abort usage
        @path = argv.shift
      end

      def execute

        update_database = cli("update-database")
        update_database.execute

        node = project.get_node(fqn)

        if path
          data = node.facts.at_path(path)
        else
          data = node.as_json
        end

        if data.is_a?(Hash)
          stdout.puts JSON.generate(
            data,
            object_nl: "\n",
            array_nl: "\n",
            indent: "  ",
            space: " "
          )
        else
          stdout.puts data
        end
      end

    end
  end
end
