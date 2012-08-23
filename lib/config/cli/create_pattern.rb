module Config
  module CLI
    class CreatePattern < Config::CLI::Base

      desc <<-STR.dent
        Generate the template for a new pattern.
      STR

      attr_accessor :topic_name
      attr_accessor :pattern_name

      def usage
        "#{name} [<topic/name>] OR [<topic> <name>]"
      end

      def parse(options, argv, env)
        if argv.size == 1
          arg = argv.shift
          if arg.include?("/")
            @topic_name, @pattern_name = arg.split("/")
          end
        else
          @topic_name = argv.shift
          @pattern_name = argv.shift
        end
        @topic_name ||= ""
        @pattern_name ||= ""
        abort usage if @topic_name.empty? || @pattern_name.empty?
      end

      def execute
        topic_name = @topic_name
        pattern_name = @pattern_name
        blueprint do
          add Config::Meta::PatternTopic do |p|
            p.root = Dir.pwd
            p.name = topic_name
          end
        end
        blueprint do
          add Config::Meta::Pattern do |p|
            p.root = Dir.pwd
            p.topic = topic_name
            p.name = pattern_name
          end
        end
      end

    end
  end
end
