# Config (a working title)

A modern server maintenance tool.

## Goals

* Simple and minimal interface and implementation. No magic.
  (MC: What do you mean by no magic? Patterns seem like they could pretty
  quickly turn into magic with their ability to cascade changes to places
  you didn't expect)
  (RC: I was referring to the ruby implementation. It should be as simple
  and clear as possible. In regards to patterns, yes I guess they could be
  considered "magic" in that they just work. I think the logging system
  goes a long way to show exactly what's happening as your patterns
  execute.)
* A clear and obvious way to do things.
* An API and supporting tools that naturally reduces errors.
* Useful information when things do go wrong.
* Git-native change management for all aspects of the system
* Supports branching for development.

## Concepts

* __Node__ A server. A Node has a Blueprint and belongs to a Cluster.
* __Blueprint__ The complete set of Patterns that describe a Node.
* __Cluster__ A collection of Nodes that work together.
* __Pattern__ A reusable concept that makes up a Blueprint or another
  Pattern. All Pattern operations are idempotent.
* __Fact__ A bit of information about a Node that cannot be changed,
  such as memory or IP address.
  (MC: But this stuff can change, there are very few things that can't
  change.)
  (RC: Good point. I'm currently wondering whether or not storing this in
  git is a good idea. Git is great because it means that every change is
  recorded in one place. But there are problems, such as deadlock issues
  if many nodes were to update their files at once. I've thought about
  branches or disconnected branches. I've also considered a simple
  redis(?) based storage engine but I don't love the dependency.)
* __Variable__ A part of a Blueprint that may be configured. Variables
  may be set on either the Node or Blueprint.
* __Service__ A long running application, generally managed by Upstart.
  A Service may be notified that something it depends on has changed.
  When that happens the Service typically restarts.
  (MC: It seems very specific to use upstart here, I don't think you
  should favor one init system over another. It also seems odd to mention
  Service at this high of a level, what about files or scripts?)
  (RC: On my initial experience with upstart it seemed like a good
  model. I agree that it doesn't need to be specific. The reason Service
  is mentioned here is that they have "notify" behavior that
  differentiates them from static patterns. If there's a way to make them
  not special, that could be even better.)
* __TODO__ is monitoring/alerting a core concept?

### Patterns

Config comes with a set of useful Patterns built in. These Patterns form
the building blocks for your own higher level Patterns and the
Blueprints that use them.

* __Directory__ A directory on disk.
* __File__ A file on disk. The contents may come from an ERB template
  or a String.
* __Link__ A symbolic (or hard) link.
* __Package__ Install a 3rd party library via apt>
* __Script__ Any executable code.

## Basic Use

Config stores everything in a git repository. And by everything we mean both
the Patterns and Blueprints that describe how we want a Node to behave, and the
Nodes themselves.

To generate a new project

    $ mkdir myproject
    $ cd myproject
    $ config-create-project

The project layout

    patterns
      [topic]/README.md
      [topic]/[pattern].rb
      [topic]/templates/[file].erb
    blueprints
      [blueprint].rb
    clusters
      [cluster].rb
      [cluster]/
        [node_id].rb
    facts
      [cluster]/[node_id].rb

To create a new server, begin by creating a Blueprint

    $ config-create-blueprint webserver
    $ vim blueprints/webserver.rb
    it "Configures a server to run example.com"

    add Nginx::Service
    add Nginx::Site do |site|
      site.host = "example.com"
      site.enabled = true
    end

This Blueprint uses two Patterns. Those Patterns might look something like this

    $ config-create-pattern nginx/service
    $ vim patterns/nginx/service.rb
    class Nginx::Service < Config::Pattern

      it "Installs nginx and creates a service to run it"

      desc "The name of the service to run"
      key :service_name, "nginx"

      def call
        package "nginx"
        file "/etc/nginx/nginx.conf" do |f|
          f.template = "nginx.conf"
        end
        service service_name
        notify service_name
      end
    end

    $ config-create-pattern nginx/site
    $ vim patterns/nginx/site.rb
    class Nginx::Site < Config::Pattern

      it "Installs a website to be hosted via nginx"

      desc "The hostname that the site should respond to"
      key :host

      desc "Whether or not the site should be enabled"
      attr :enabled, true

      def call
        file "/etc/nginx/sites-available/#{host}" do |f|
          f.template = "site.erb"
        end
        if enabled
          link "/etc/nginx/sites-available/#{host}" => "/etc/nginx/sites-enabled/#{host}"
        end
        notify "nginx"
      end
    end

Next we'll create a Cluster to contain the server. Let's call it
'production'.

    $ config-create-cluster production
    $ vim clusters/production.rb
    # nothing to see here yet.

Check these files into git and push to your remote repository. You're
now ready to boot a server.

    $ config-ec2-create-node --blueprint=webserver --cluster=production

(MC: I'm curious how it has access to my git repository)
(RC: Me too. A secrets manager is a big missing piece here. See also
whether or not this git access should really be read/write or just
read)

Here we've specified the two required parameters: The Blueprint used to
configure the server, and the Cluster that the resulting Node will
belong to. We wait for AWS to provision us a server, and once the server
boots it will automatically configure itself and store its information
in this git repo. Once those commits exist, pull them down. Use the
`--wait` flag to let Config do that for you.

    $ git pull
    + clusters/production/[node_id].rb
    + facts/production_[node_id].json

Two new files appear. One contains our configuration of the Node, at
this point its only the Blueprint and Cluster we've configured. You can
use this file in the future to set Variables used by the blueprint just
like a Cluster file.

    $ cat clusters/production/[node_id].rb
    cluster   :production
    blueprint :webserver

The facts file is contains information gathered by Ohai.

    $ cat facts/production/[node_id].json
    { "ec2": { "instance_id": "i-91923", "ip_address": "127.0.0.1", ... } }

## Testing

Because developing and testing against a real server is slow, Config
provides several tools to help you understand what will happen before
you get there.

### Validate

Config can validate that your files are well formed and that all required
variables have been specified.

    $ config-validate

If something is invalid, Config will tell you.

    blueprints/test.rb
    Nginx::Site missing value for :name (The hostname that the site should respond to)

    patterns/nginx/service.rb
    Nginx::Service missing description for attribute :service_name

### Try a Blueprint

Once the parts are valid, you might want to get an idea of what the
result of a Blueprint will be.

    $ config-try-blueprint blueprints/production.rb

The result of this command is a record of everything that would happen.
It might look something like this, showing the hierarchy of patterns
used and their results.

    # Nginx::Service
      # Config::Patterns::Package
      Installed nginx
      # Config::Patterns::File
      Created /etc/nginx/nginx.conf
          user www;
          worker_processes 1;
          ...
      Set owner of /etc/nginx/nginx.conf to www
      # Config::Patterns::File
      Created /etc/init.d/nginx.conf
          ...
          exec /etc/nginx/bin/nginx -c /etc/nginx/nginx.conf
          ...
      Set owner of /etc/init.d/nginx.conf to root
      ...
    # Nginx::Site
      # Config::Patterns::File
      Created /etc/nginx/sites-available/example.com
          ...
      # Config::Patterns::Link
      Created /etc/nginx/sites-available/example.com => /etc/nginx/sites-enabled/example.com
    Notify nginx

## What is a Blueprint

A Blueprint uses one or more Patterns to describe a server. It may be
configured via Variables from the current Node or the current Cluster.
Blueprints are stored in `blueprints/[name].rb`.

### How a Blueprint is executed

Blueprint execution occurs in a few steps:

1. **Accumulate** Recursively traverse all Patterns.
1. **Validate** Ensure that all Patterns have been defined correctly and
   that all Attributes have been set.
1. **Resolve** Detect conflicting Patterns. Mark duplicate Patterns to
   execute in *skip* mode.
   (MC: What are conflicting patterns?)
   (RC: See the section below 'Uniqueness, Conflict and Equality')
1. **Destroy** If a previous execution exists, find any Patterns that
   executed previously but would not execute now. Mark those Patterns
   to execute in *destroy* mode.
   (MC: This is good)
   (RC: Thanks! The lack of this in chef drives me crazy)
1. **Execute** Execute all Patterns.

## What is a Pattern

A Pattern is a reusable bit of configuration. Patterns are composable,
and so therefore may be of any size and scope. Low level patterns such
as `File` and `Package` are provided by Config. You can use these
patterns to create your own, higher level patterns. Patterns are stored
in `patterns/[topic]/[name].rb`.

All patterns inherit from `Config::Pattern`. A trivial example.

    class LastRunAt < Config::Pattern
      def call
        file "/etc/config_was_run" do |f|
          f.content = Time.now.to_s
        end
      end
    end

This Pattern simply stores the last time that Config was run at
`/etc/config_was_run`. We defined `call` to use the builtin `File`
pattern via the `file` helper. To expose what's going on here, let's
rewrite it without the helper.

    def call
      add Config::Patterns::File do |f|
        f.path = "/etc/config_was_run"
        f.content = Time.now.to_s
      end
    end

With this we've exposed another important method in Pattern's API,
`add`. `add` takes a Pattern class and an optional configuration block.
More importantly, we've exposed that by instantiating a Pattern we have
not executed it. Put another way: there are two phases to using a
Pattern: Accumulation and Execution. To configure a server, obviously we
need to Execute the Pattern. Before doing so, Config accumulates all of
the patterns that will run in order to validate, detect duplicates and
conflicts.

### Attributes

To be useful in more than one situation, a Pattern uses variables to
alter its behavior. We call those Attributes and they are another of the
APIs that `Config::Pattern` exposes. Let's look at what
`Config::Patterns::File` as used above might look like.

    class Config::Patterns::File < Config::Pattern

      desc "The path of the file"
      key  :path

      desc "The contents of the file"
      attr :content

      def call
        ...
      end
    end

The Attributes API has three methods. `desc` describes the purpose of an
attribute, `key` defines an attribute that must be unique for all
instances of this Pattern, and `attr` defines a simple variable.

Pass a second argument to `attr` or `key` to set a default value.

    attr :content, "Hello"

**Important** All attributes of a Pattern must have a value. If nil is
an acceptable value, you must set that as the default.

#### Keys

A Pattern's Key attributes describe what it means to be a unique
instance of a Pattern. For example in our File example, the `path` is
defined as Key. By defining `path` as a Key, Config will ensure that we
have one and only one file at that path.

#### Uniqueness, Conflict and Equality

An instance of a Pattern class is said to be *unique* if the value of its
keys is different from another. These two files are unique because they
are at different paths.

    add Config::Patterns::File do |f|
      f.path = "/tmp/file_1"
    end
    add Config::Patterns::File do |f|
      f.path = "/tmp/file_2"
    end

On the other hand, these two files are in *conflict* because they have
identical keys, but the rest of their attributes are not identical.
Config will not allow you to execute a set of patterns that are in
conflict.

    add Config::Patterns::File do |f|
      f.path = "/tmp/file"
      f.content = "hello"
    end
    add Config::Patterns::File do |f|
      f.path = "/tmp/file"
      f.content = "world"
    end

Two instances of a Pattern are said to be *equal* if all of their
attributes are equal. Config will only execute the first of these
patterns, noting explicitly that the second was skipped.

    add Config::Patterns::File do |f|
      f.path = "/tmp/file"
      f.content = "hello"
    end
    add Config::Patterns::File do |f|
      f.path = "/tmp/file"
      f.content = "hello"
    end

It's worth noting that if a Pattern defines no keys, it is always unique
among other instances of that Pattern. Be careful if your Pattern has
this quality as it may indicate a deeper problem with the design.

(MC: Interesting, this is kind of like debian provides)
(RC: Tell me more about this?)

### Describe & Logging

Config's logging is one the most important tools to understand what's
happening on your nodes. The Pattern API allows you to specify a name
for your pattern via either the `describe` method or the `to_s` method.
`to_s` is used to identify the pattern when it's logged.

    # The default implementation of #to_s includes the class name
    # and the key attributes.
    # => "[File path:\"/var/log/nginx.log\"]"

    # Override `describe` to change what's within the square brackets.
    def describe
      "A file at #{path}"
    end
    # => "[A file at /var/log/nginx.log]"

    # Override `to_s` to change the full description
    def to_s
      "<#{path}>
    end
    # => "</var/log/nginx.log>"

### Create & Destroy

The Pattern API has two additional methods: `create` and `destroy`.

During the Accumulation phase, Config collects all of the patterns and
determines uniqueness. Once the set of patterns is found, each pattern
is executed by calling either its `create` or `destroy` method.

* `create` Alter the node.
* `destroy` Reverse the alteration.

*If your Pattern only uses other patterns, there is no need to
implement `create` or `destroy`.*

A Pattern is destroyed when it has been removed from the set since the
last execution. Config tracks the set of Patterns on each execution to
determine what has been removed. See Lifecycle for more information.

(MC: An implementation detail but what happens on a config run failure?
Will it remember that it didn't successfully complete and then correctly
attempt to destroy?)
(RC: Good question. Sounds like it should.)

## What is a Cluster

A Cluster is a set of Nodes that work together. The simplest way to use
clusters is to create multiple instances of your application (typically
called an 'environment'). Besides acting as a grouping mechanism, a
Cluster allows configuration of your blueprints. Cluster definitions are
stored in `clusters/[name].rb`

    $ config-create-cluster production
    $ vim clusters/production.rb
    blueprint :webserver,
      host: "example.com",
      enabled: true

Here we have created a `production` cluster and configured some
variables for the `webserver`. When a Blueprint executes within this
Cluster, it may access variables to alter its behavior.

    $ vim blueprints/webserver.rb
    add Nginx::Site do |site|
      site.host = cluster.host
      site.enabled = cluster.enabled
    end

*TODO: Should variables be blueprint specific, grouped in to arbitrary
buckets, or something else?`

**Ideas** I believe that the configuration of each blueprint should be
clear, and that within the blueprint you should not pull variables from
many locations. The minimum locations should be kept to 1) cluster 2)
node variables, 3) node facts. However, there is a need for multiple
blueprints to need access to the same variables while keeping the
definition of those values DRY. Some kind of reference system could be
useful.

    set :shared_variables,
      website_host: "example.com"

    blueprint :webserver,
      host: -> { shared_variables.website_host },
      enabled: true

(MC: I'm not sure why you would need more than cluster, node variables
and node facts. It seems that the reference system is just going to add
complexity.)
(RC: I'm probably overly concerned with DRYness of inputs. It might be
wise to show some real world situations and then decide if they're
probelmatic or not.)

**Ideas** Another dimension of reuse might be blueprint inheritance. I
could definitely see it useful to define a "base" blueprint from which
others can inherit. What might that look like?

    $ blueprints/base.rb
    file "~/.ssh/authorized_keys" do |f|
      f.template = "authorized_keys.erb"
    end

    $ blueprints/webserver.rb
    inherit :base
    # Obviously the question of multiple inheritance should be asked
    # here. I default to no for simplicity sake but there doesn't seem
    # to be any real harm.
    add Nginx::Server

    $ cat clusters/production.rb
    blueprint :base,
      ssh_keys: ["..."]
    blueprint :webserver,
      host: "example.com"

(MC: I think I would leave this out, as I think having blueprints being
more explict and not having cascading changes will be less magical)
(RC: I totally agree, again DRYness is nagging me but some real world
cases would be useful to see here)

### Nodes

A cluster is only useful once Nodes are running within it. Each Node has
access to the configuration of other nodes within its cluster, and
*only* within its cluster. You need not fear creating a staging cluster
whose configuration points to the production database.

To access facts about another node in the cluster, you may perform
simple queries.

    node = cluster.find_node(MySQL::Server => { master: true })
    node.facts.public_ip

## Advanced Configuration

Following are more advanced ways to use Config. You can probably do a lot
without these techniques.

### Extending a Pattern

At times you may need to further extend an existing Pattern. For example, Our
`Nginx::Service` pattern is a high level service. It installs Nginx and then
uses Upstart to run it. Say we like this pattern, but need to more carefully
control when the underlying Upstart service starts. Use the `intercept` method
to tap that Upstart service and change its configuration.

    add Nginx::Service do |nginx|
      nginx.intercept Config::Patterns::Upstart do |upstart|
        upstart.start_on = "some event"
      end
    end

### Branch-based development

Something here about a workflow like this:

* Create a new branch
* Make changes to patterns, etc
* Create nodes
  (MC: How would the nodes know to use this branch?)
  (RC: Good question. Much like node facts, I've been pondering where
  this information would be stored. If there's a database of some sort,
  obviously that could be the source of truth. Git branches aren't great
  because then you introduce conflicts not to mention it's super
  confusing. A special disconnected branch might actually make sense here.
  Something like `config-branches` where you would specify which branch a
  Cluster should run.)
* Merging this to master would be weird, right?
  (MC: it actually makes sense to me)
  (RC: oh awesome, I think it could totally make sense. What about
  deleting the branch?)
* Should a Cluster indicate the branch(es) that are valid to boot from?
  (MC: also which branches should they run from?)
  (RC: yep, you obviouly see where I'm going here, probably better than
  I do at this point)
* Is this how one might do development?

## Reference

A brief overview of Config's APIs and tools.

### The Pattern API

Class methods DSL.

* `desc` Describe an attribute.
* `key` Define a key attribute.
* `attr` Define an attribute.

Methods you may override in your Pattern subclass.

* `validate` Perform deeper validation of attributes before execution.
* `call` Add other Patterns. Don't perform any operations that alter the
  node, do that in `create`.
* `prepare` Prepare and log data before execution.
* `create` Perform operations that alter the Node.
* `destroy` Perform operations that undo the alteration of the Node.
* `describe` Change the string representation of your Pattern.
* `to_s` Change the full string representation of your Pattern.

Helpers available during Pattern execution.

* `validation_errors` An appendable (`<<`) object that accumulates
  issues during `validate`.
* `log` A `Config::Log` object. Write to it with `<<`.
* `add(klass, &block)` Add a sub-pattern. Provide a block to set
  attributes on the instantiated pattern.
* The `Config::Patterns` helpers.

### The Blueprint API

The Blueprint API is a subset of the Pattern API. Blueprints act as a
single entrypoint for a set of patterns.

* `log`
* `add`
* The `Config::Patterns` helpers.

### Config::Patterns helpers

`Config::Patterns` contains a number of methods to make using the core
patterns simpler. You may extend this module to add your own helpers.

* `file(path)` Add a `Config::Patterns::File`. Using this helper
  also provides the `template=` method. Use this method to assign the
template file name, expected to live at
`patterns/[topic]/templates/[file]`.
* `dir(path)` Add a `Config::Patterns::Directory`.

## Authors

* Ryan Carver (ryan@ryancarver.com / @rcarver)

## License

Copyright 2012 Ryan Carver. Licensed under MIT.
