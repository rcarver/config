module Config
  class Node

    def initialize(cluster_name, blueprint_name, identity)
      @cluster_name = cluster_name
      @blueprint_name = blueprint_name
      @identity = identity
    end

    attr :cluster_name
    attr :blueprint_name
    attr :identity

    attr_accessor :facts

    def fqn
      [cluster_name, blueprint_name, identity].join('-')
    end

    def as_json
      {
        cluster: cluster_name.to_s,
        blueprint: blueprint_name.to_s,
        identity: identity.to_s,
        facts: facts || {}
      }
    end

  end
end
