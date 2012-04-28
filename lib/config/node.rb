module Config
  class Node
    include Config::Core::Loggable

    attr_accessor :facts
    attr_accessor :configuration
    attr_accessor :previous_accumulation

    def execute_blueprint(blueprint)
      blueprint.facts = facts
      blueprint.configuration = configuration
      blueprint.previous_accumulation = previous_accumulation
      blueprint.execute
    end
  end
end
