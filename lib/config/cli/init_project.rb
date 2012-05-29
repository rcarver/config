module Config
  module CLI
    class InitProject < Config::CLI::Base

      def usage
        "#{name}"
      end

      def execute
        blueprint do
          add Config::Meta::Project do |p|
            p.root = Dir.pwd
          end
        end
      end

    end
  end
end

