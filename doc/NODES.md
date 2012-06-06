# Nodes

A node is a single server. A node must belong to **one and only one**
[blueprint](BLUEPRINTS.md) and **one and only one**
[cluster](CLUSTERS.md). Each node also must also have a unique
identifier. The combination of `cluster`, `blueprint` and `identity`
together form the node's **FQN**, or *Fully Qualified Name*.  The three
items are concatenated together with a dash (-) to form the FQN.

    production-webserver-1

    cluster = "production"
    blueprint = "webserver"
    identity = "1"

During [bootstrap](BOOTSTRAP.md), a node's `hostname` is set to the FQN.
This simple fact is critical to how Config configures a server.

  1. The `hostname` alone determines the behavior of the node.
  2. The identity and role of a node is always clear and consistent.

## Syntax

Nodes are stored in two ways. Primarily, they are stored in the project
database at `nodes/<fqn>.json`. This file contains [node facts](#facts)
and is maintained by the node itself. 

Nodes may also be represented in a project file at `nodes/<fqn>.rb`.
The syntax of this file is exactly the same as [cluster
syntax](CLUSTERS.md#syntax) and allows you to override the cluster
configuration in special cases. You should use this carefully - if a
node has excessive custom configuration consider whether it is better
represented with a new [blueprint](BLUEPRINTS.md).

## Facts

TODO: describe node facts.

## Managing nodes

Each node maintains information about itself in the project database.
Config provides commands to inspect and manage those entries.

  * [`config-show-node`](../man/config-show-node.1.md) gives you
    information about the node. 
