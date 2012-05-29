module Config
  module CLI
    class CreateTopic < Config::CLI::Base

      attr_accessor :topic_names

      def usage
        "#{name} <name>..."
      end

      def parse(options, argv, env)
        abort usage if argv.empty?
        @topic_names = argv
      end

      def execute
        topic_names = @topic_names
        blueprint do
          topic_names.each do |name|
            add Config::Meta::PatternTopic do |p|
              p.root = Dir.pwd
              p.name = name
            end
          end
        end
      end

    end
  end
end


