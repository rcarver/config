# Blueprints

A blueprint is the single, complete definition of the configuration of a
[node](NODES.md). A node must have **one and only one** blueprint
associated with it.

A blueprint uses one or more [patterns](PATTERNS.md) to describe that
configuration. The blueprint is responsible for configuring each top
level pattern, either via static values or from the
[variables](#variables) available when the blueprint executes. Let's
look at a simple example.

    # blueprints/sample.rb
    file "/tmp/sample" do |f|
      f.content = "Config created this"
    end

This is as simple as it gets. The blueprint uses the `file` pattern to
create a single file on disk. That file's content is static - it's the
same for every node.

## Variables

A blueprint always executes in the context of a [cluster](CLUSTERS.md)
and a [node](NODES.md). We can pull data from those sources in order to
customize the output of the blueprint. For example, we can include facts
about a node in the file's content.

    # blueprints/sample.rb
    file "/tmp/sample" do |f|
      f.content = "Config created this on #{node.ipaddress}"
    end

Or, we could pull configuration from the cluster. See
[clusters](CLUSTERS.md) to learn how clusters work, but for now try
this.
  
    # clusters/mycluster.rb
    configure :messages,
      greeting: "hello world"
    
    # blueprints/sample.rb
    file "/tmp/sample" do |f|
      f.content = "Config says #{messages.greeting}"
    end

By customizing a blueprint based on the cluster and/or node that it
executes on, a single blueprint may satisfy a range of scenarios.

## Syntax

Blueprint files are stored in `blueprints/<name>.rb`. The program
[`config-create-blueprint
<name>`](../man/config-create-blueprint.1.md) will generate a template
for you.

The syntax of a blueprint file is much like a pattern with a few notable
additions. 

  * `node` represents the current node. See [the node](#the-current-node).
  * `cluster` represents the current cluster. See [the
    cluster](#the-current-cluster).
  * `<name>` any other name is expected to represent a configuration
    group. See [the config](#the-current-config).

### The current node

TODO: describe node/facts syntax.

### The current config

TODO: describe configuration groups.

### The current cluster

TODO: describe cluster searches.

# Execution

TODO: describe the phases of execution.

### Execution in detail

A blueprint executes in a few distinct phases. To be understand how it's
interpreted, 

1. **Accumulate** Recursively traverse all patterns.
1. **Validate** Ensure that all patterns have been defined correctly and
   that all attributes have been set.
1. **Resolve** Detect conflicting Patterns. Mark duplicate patterns to
   execute in *skip* mode.
1. **Destroy** If a previous execution exists, find any patterns that
   executed previously but would not execute now. Mark those patterns
   to execute in *destroy* mode.
1. **Execute** Execute all patterns.

## Reference

DSL for `blueprints/<blueprint>.rb`.

The execution environment.

  * `configure` - The current configuration. 
  * `node` - Node facts.

Execute patterns.

  * `add`
  * `Config::Patterns` helpers.

Examples.

    add Config::Patterns::File do |f|
      f.path = "/tmp/hello"
      f.content = <<-STR
        Hello from #{node.public_ip}
        #{configure.sample.message}
      STR
    end

