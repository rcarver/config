# Config (a working title)

A modern, distributed provisioning tool.

**Product Status:** Config is very alpha. Feedback of all types is
welcome, especially issues and pull requests. Vagrant is the ideal way
to get started; see below.

[![Build Status](https://secure.travis-ci.org/rcarver/config.png?branch=master)](http://travis-ci.org/rcarver/config)

## Goals

  * Simple and minimal interface and implementation.
  * A clear and obvious way to do things.
  * An API and supporting tools that naturally reduces errors.
  * Useful information when things do go wrong.
  * Git-native change management for all aspects of the system.
  * Enable branch-based development for operations.

## Introduction

Config aims to be simple. There are a few key concepts to understand.

  * [Node](config/tree/master/doc/NODES.md) A server. A node has a
    blueprint and belongs to a cluster.
  * [Blueprint](config/tree/master/doc/BLUEPRINTS.md) The complete set
    of patterns that describe a node.
  * [Cluster](config/tree/master/doc/CLUSTERS.md) A collection of nodes
    that work together.
  * [Pattern](config/tree/master/doc/PATTERNS.md) A reusable concept
    that makes up a blueprint or another pattern.

## Getting started

The [Getting Started guide](config/tree/master/doc/GETTING_STARTED.md)
will have you up and running in no time.

## Learning more

Documentation is in the [doc directory](config/tree/master/doc).

## Integration

Config is the perfect complement to [Vagrant](http://vagrantup.com/).
These tools together are the best way to manage your development
environment. [Learn more](config/tree/master/doc/VAGRANT.md).

Config is well suited for managing instances at Amazon EC2. Tools are
limited right now, but are coming soon.

## Authors

* Ryan Carver (ryan@ryancarver.com / @rcarver)

## License

Copyright 2012 Ryan Carver. MIT License, see LICENSE for details.

