module Config
  module CLI
    class CreateCluster < Config::CLI::Base

      attr_accessor :cluster_names

      def usage
        "#{name} <name>..."
      end

      def parse(options, argv, env)
        abort usage if argv.empty?
        @cluster_names = argv
      end

      def execute
        cluster_names = @cluster_names
        blueprint do
          cluster_names.each do |name|
            add Config::Meta::Cluster do |p|
              p.root = Dir.pwd
              p.name = name
            end
          end
        end
      end

    end
  end
end

