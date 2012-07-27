module Config
  module Spy
    class ClusterContext
      include Config::Core::Loggable

      def name
        log << "Read cluster.name => \"fake:spy_cluster\""
        "spy_cluster"
      end

      # TODO: implement fake finders
    end
  end
end
