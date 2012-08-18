module Config
  class Node

    # Parse a FQN or FQDN to create a Node.
    #
    # fqn - String.
    #
    # Examples
    #
    #   Node.from_fqn("prod-webserver-1")
    #   Node.from_fqn("prod-webserver-1.example.com")
    #   Node.from_fqn("prod-webserver-1.internal.example.com")
    #
    # Returns a Config::Node.
    # Raises ArgumentError if the input cannot be interpreted as an fqn.
    def self.from_fqn(fqn)
      a, *_ = (fqn || "").split(".")
      parts = (a || "").split("-")
      unless parts.size == 3
        raise ArgumentError, "Expected a fqn: #{a.inspect}"
      end
      new(*parts)
    end

    def self.from_json(json)
      node = new(
        json["node"]["cluster"],
        json["node"]["blueprint"],
        json["node"]["identity"]
      )
      node.facts = Config::Facts.from_json(json["facts"])
      node
    end

    def initialize(cluster_name, blueprint_name, identity)
      # TODO: enforce that none of the args may contain a dash.
      @cluster_name = cluster_name
      @blueprint_name = blueprint_name
      @identity = identity
      @facts = Config::Facts.new({})
    end

    attr :cluster_name
    attr :blueprint_name
    attr :identity

    attr_accessor :facts

    # Public: Get the fully qualified node name. This name
    # is used as the `hostname` of a node in order to identify it
    # consistently thoughout the system.
    #
    # Examples
    #
    #   node = Node.new("prod", "webserver", "ix88")
    #   node.fqn # => "prod-webserver-ix88"
    #
    # Returns a String.
    def fqn
      [cluster_name, blueprint_name, identity].join('-')
    end

    def as_json
      {
        node: {
          cluster: cluster_name.to_s,
          blueprint: blueprint_name.to_s,
          identity: identity.to_s,
        },
        facts: facts.as_json
      }
    end

    def ==(other)
      fqn == other.fqn
    end

    alias eql? ==

    def hash
      fqn.hash
    end

  end
end
