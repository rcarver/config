# Config (a working title)

A modern, distributed server configuration tool.

## Goals

* Simple and minimal interface and implementation. No magic.
* A clear and obvious way to do things.
* An API and supporting tools that naturally reduces errors.
* Useful information when things do go wrong.
* Git-native change management for all aspects of the system.
* Branch-based development.

## Introduction

Config aims to be simple. There are a few key concepts to understand.

* [Node](tree/master/doc/NODES.md) A server. A node has a blueprint and
  belongs to a cluster.
* [Blueprint](tree/master/doc/BLUEPRINTS.md) The complete set of
  patterns that describe a node.
* [Cluster](tree/master/doc/CLUSTERS.md) A collection of nodes that work
  together.
* [Pattern](tree/master/doc/PATTERNS.md) A reusable concept that makes
  up a blueprint or another pattern. 
* [Hub](tree/master/doc/HUB.md) A computer that's used to bootstrap
  nodes. This could be any node in the system or your development
  workstation.

## Getting started

The [Getting Started guide](tree/master/doc/GETTING_STARTED.md) will
have you up and running in no time.

## Authors

* Ryan Carver (ryan@ryancarver.com / @rcarver)

## License

Copyright 2012 Ryan Carver. Licensed under MIT.
