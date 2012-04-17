module Config
  class Node
    include Config::Core::Loggable

    def initialize(cluster, blueprint)
      @cluster = cluster
      @blueprint = blueprint
    end

    attr_accessor :facts
    attr_accessor :previous_accumulation

    def execute
      @blueprint.node = self
      @blueprint.cluster = @cluster
      @blueprint.execute(@previous_accumulation)
    end
  end
end
