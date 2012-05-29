module Config
  class Project

    UnknownNode = Class.new(StandardError)
    UnknownCluster = Class.new(StandardError)
    UnknownBlueprint = Class.new(StandardError)

    def initialize(project_path, data_path)
      @loader = Config::Core::ProjectLoader.new(project_path)
      @data_path = Pathname.new(data_path).cleanpath
      @data_dir = Config::Data::Dir.new(@data_path)
      @git_repo = Config::Core::GitRepo.new(@path)
    end

    def require_all
      @loader.require_all
    end

    def update
      return :dirty unless @git_repo.clean_status?

      @git_repo.pull_rebase
      :updated
    end

    # This is a bash implementation of #update It's written in bash so that it
    # can be used during the bootstrap process. It's stored here so that it can
    # be used both in the config-update-project command and the node-based
    # config-run command. It's also stored here so that the script is visible
    # alongside logically similar code.
    #
    # Returns a String.
    def update_project_script
      <<-STR
# Require that the working directory has no uncommited changes.
if [ -n "$(git status --porcelain)" ]; then
  echo "git repo is not totally clean." >&2
  exit 1
fi

# Pull in the latest changes cleanly.
git pull --rebase
      STR
    end

    # Get the data directory. The data directory stores information
    # about the state of your system.
    #
    # Returns a Config::Data::Dir.
    def data_dir
      @data_path.mkpath # TODO: don't mkpath
      @data_dir
    end

    # Get the database. The database stores information about your
    # nodes.
    #
    # Returns a Config::Data::Database.
    def database
      @database or data_dir.database
    end

    # Get the project Hub. The Hub describes centralized aspects of your
    # system.
    #
    # Returns a Config::Hub.
    def hub
      @hub ||= @loader.get_hub
    end

    # Get all of the SSH hosts that are used during execution.
    #
    # Returns an Array of String.
    def ssh_hosts
      hub.ssh_hosts
    end

    # Update the stored node data by inspecting the current execution
    # environment.
    #
    # fqn - String Node FQN.
    #
    # Returns a Config::Node.
    def update_node(fqn)
      node = database.find_node(fqn) || Config::Node.from_fqn(fqn)
      node.facts = fact_inventor.call
      database.update_node(node)
      node
    end

    # Remove the node from the database.
    #
    # fqn - String Node FQN.
    #
    # Returns nothing.
    def remove_node(fqn)
      node = database.find_node(fqn)
      database.remove_node(node) if node
      nil
    end

    # Execute the node's blueprint.
    #
    # fqn - String Node FQN.
    #
    # Returns a Config::Node.
    def execute_node(fqn, previous_accumulation = nil)
      @loader.require_all

      node = get_node(fqn)
      cluster = get_cluster(node.cluster_name)
      blueprint = get_blueprint(node.blueprint_name)

      # Configure.
      blueprint.facts = node.facts
      blueprint.configuration = cluster.configuration
      blueprint.previous_accumulation = previous_accumulation if previous_accumulation

      # Execute.
      accumulation = blueprint.accumulate
      blueprint.validate
      blueprint.execute

      accumulation
    end

    # Execute a blueprint in noop mode.
    #
    # blueprint_name - String name of the blueprint.
    # cluster_name   - String name of the cluster (default: execute with
    #                  a Spy cluster)
    #
    # Returns nothing.
    def try_blueprint(blueprint_name, cluster_name = nil)
      @loader.require_all

      blueprint = get_blueprint(blueprint_name)

      # Configure.
      if cluster_name
        cluster = get_cluster(cluster_name)
        blueprint.configuration = cluster.configuration
      else
        blueprint.configuration = Config::Spy::Configuration.new
      end
      blueprint.facts = Config::Spy::Facts.new

      # Execute.
      accumulation = blueprint.noop!
      blueprint.validate
      blueprint.execute

      accumulation
    end

    def get_cluster(name)
      @loader.get_cluster(name) or raise UnknownCluster, "Cluster #{name.inspect} was not found"
    end

    def get_blueprint(name)
      @loader.get_blueprint(name) or raise UnknownBlueprint, "Blueprint #{name.inspect} was not found"
    end

    def get_node(name)
      database.find_node(name) or raise UnknownNode, "Node #{name.inspect} was not found"
    end

    #
    # Internal / Dependency Injection
    #

    attr_writer :loader
    attr_writer :git_repo
    attr_writer :database
    attr_writer :fact_inventor

    def fact_inventor
      @fact_inventor || proc { Config::Core::Facts.invent }
    end

  end
end
