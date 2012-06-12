# Clusters

A cluster groups a set of [nodes](NODES.md). A node must belong to **one
and only one** cluster. The cluster generally provides configuration data
used by node [blueprints](BLUEPRINTS.md). That configuration data allows
nodes in one cluster to behave differently than nodes in another
cluster. The simplest use of clusters is to define "production" vs
"staging" environments for your application.

Let's look at an example. 

    # clusters/production.rb
    configure :website,
      host: "example.com"

    # clusters/staging.rb
    configure :website,
      host: "staging.example.com"

Here we've defined two clusters and configured the `website.host`
differently in each. A blueprint that executes within either of these
clusters can use this configuration data. A ficticious blueprint might
look like this.

    # blueprints/webserver.rb
    add Nginx::Site do |site|
      site.host = cluster.website.host
    end

The result is that we can configure our website to respond to a
different host name when a node runs in the production cluster vs. the
staging cluster.

## Syntax

Cluster files are stored in `clusters/<name>.rb`. The program
[`config-create-cluster
<name>`](../man/config-create-cluster.1.md) will generate a template
for you.

Cluster syntax is simple. There is one keyword, `configure`. The
argument to `configure` is called the "group" and is specified using a
Ruby Symbol. A Symbol is a variable name prefixed by a colon. Following
the group are any number of key/value pairs. These pairs define the
variables available within the group. The key/value pairs are defined in
JSON-like syntax.

    configure :name_of_group,
      key1: "one",
      key2: 123
      
By convention, the name of the group, and each key/value pair is defined
on its own line. 

## Blueprint syntax

When accessed within a blueprint, a cluster can do a few more things.
[Find out more](BLUEPRINTS.md#the-current-cluster).

## Reference

DSL for `clusters/<cluster>.rb`.

  * `configure` Define configuration variables.

Examples.

    configure :webserver,
      hostname: "example.com",
      greeting: "Hello World"

