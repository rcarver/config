module Config
  class Node

    def initialize(cluster, blueprint, identity)
      @cluster = cluster
      @blueprint = blueprint
      @identity = identity
    end

    attr :cluster
    attr :blueprint
    attr :identity

    attr_accessor :facts

    def fqn
      [cluster, blueprint, identity].join('-')
    end

    def as_json
      {
        cluster: cluster.to_s,
        blueprint: blueprint.to_s,
        identity: identity.to_s,
        facts: facts || {}
      }
    end

  end
end
