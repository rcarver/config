# Config (a working title)

A modern server maintenance tool.

## Goals

* Simple and minimal interface and implementation. No magic.
* A clear and obvious way to do things.
* An API and supporting tools that naturally reduces errors.
* Useful information when things do go wrong.
* Git-native change management for all aspects of the system.
* Branch-based development for ops.

## Concepts

* __Node__ A server. A Node has a Blueprint and belongs to a Cluster.
* __Blueprint__ The complete set of Patterns that describe a Node.
* __Cluster__ A collection of Nodes that work together.
* __Pattern__ A reusable concept that makes up a Blueprint or another
  Pattern. All Pattern operations are idempotent.
* __Fact__ A bit of information that's implicit to a Node.
* __Variable__ A part of a Blueprint that may be configured. Variables
  may be set on either the Node or Cluster.
* __Service__ A long running application, generally managed by Upstart.
  A Service may be notified that something it depends on has changed.
  When that happens the Service typically restarts.
* __Hub__ A special node that is used to bootstrap other nodes. This can
  be any node in the system or your development computer.
* __TODO__ is monitoring/alerting a core concept?

### Patterns

Config comes with a set of useful Patterns built in. These Patterns form
the building blocks for your own higher level Patterns and the
Blueprints that use them.

* __Directory__ A directory on disk.
* __File__ A file on disk. The contents may come from an ERB template
  or a String.
* __Link__ A symbolic (or hard) link.
* __Package__ Install a 3rd party library via apt.
* __Script__ Any executable code (generally bash).

## Basic Use

Config stores everything in a git repository. And by everything we mean
both the Patterns and Blueprints that describe how we want a Node to
behave, and the Nodes themselves. To do this, Config uses two git
repositories. The first, called the "project" repo, stores code and
configuration that you write. The second, called the "data" repo is
maintained automatically the nodes. It acts as a database describing the
state of your system.

To initialize  project

    $ mkdir myproject
    $ cd myproject
    $ git init
    $ config-init-project

The project layout

    patterns
      [topic]/README.md
      [topic]/[pattern].rb
      [topic]/templates/[file].erb
    blueprints
      [blueprint].rb
    clusters
      [cluster].rb
    nodes
      [node_fqn].rb

To create a new server, begin by creating a Blueprint

    $ config-create-blueprint webserver
    $ vim blueprints/webserver.rb
    add Nginx::Service
    add Nginx::Site do |site|
      site.host = "example.com"
      site.enabled = true
    end

This Blueprint uses two Patterns. Those Patterns might look something like this

    $ config-create-pattern nginx/service
    $ vim patterns/nginx/service.rb
    class Nginx::Service < Config::Pattern

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
    # Nothing to see here yet. In the future we can use this file to
    # configure the production cluster differently than another cluster.

Check these files into git and push to your remote repository. You're
now ready to boot a server.

    $ config-ec2-create-node --cluster=production --blueprint=webserver

Here we've specified the two required parameters: The Blueprint used to
configure the server, and the Cluster that the resulting Node will
belong to. We wait for AWS to provision us a server, and once the server
boots it will automatically configure itself and store its information
in the data repo.

    $ config-update-database

The database now contains our new node. Specifically, it contains the
file `nodes/production-webserver-i9999.json` which contains a wealth of
information about the server (provided by Ohai).

## Testing

Because developing and testing against a real server is slow, Config
provides several tools to help you understand what will happen before
you get there.

### Try a Blueprint

Once the parts are valid, you might want to get an idea of what the
result of a Blueprint will be.

    $ config-try-blueprint webserver production

The result of this command is a record of everything that would happen
if a webserver executes within the production clsuter. It might look
something like this, showing the hierarchy of patterns used and their
results.

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

You can also try a blueprint without specifying a cluster. Doing so uses
a "spy" cluster to collect all of the variables required to execute the
blueprint.

    $ config-try-blueprint production

## What is a Blueprint

A Blueprint uses one or more patterns to describe a node. It may be
configured via variables from the current node or the current cluster.
Blueprints are stored in `blueprints/[name].rb`.

### How a Blueprint is executed

Blueprint execution occurs in a few steps:

1. **Accumulate** Recursively traverse all patterns.
1. **Validate** Ensure that all patterns have been defined correctly and
   that all attributes have been set.
1. **Resolve** Detect conflicting Patterns. Mark duplicate patterns to
   execute in *skip* mode.
1. **Destroy** If a previous execution exists, find any patterns that
   executed previously but would not execute now. Mark those patterns
   to execute in *destroy* mode.
1. **Execute** Execute all patterns.

## What is a Pattern

A Pattern is a reusable bit of configuration. Patterns are composable,
and so therefore may be of any size and scope. Low level patterns such
as `File` and `Package` are provided by Config. You can use these
patterns to create your own, higher level patterns. Patterns are stored
in `patterns/[topic]/[name].rb`.

All patterns inherit from `Config::Pattern`. A trivial example looks
like this.

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

With this we've exposed an important method in Pattern's API.  `add`
takes a Pattern class and an optional configuration block. You can use
the `add` method to accumulate any pattern class. It's also worth noting
here that the `call` method should never modify the underlying system.
It *only* describes the actions that will occur should you decide to do
so. This separation is critical to Config's builtin testing tools.

### Attributes

To be useful in more than one situation, a pattern uses variables to
alter its behavior. We call those Attributes and they are another of the
APIs that `Config::Pattern` exposes. Let's look at what
`Config::Patterns::File` as used above might look like.

    class Config::Patterns::File < Config::Pattern

      desc "The path of the file"
      key  :path

      desc "The contents of the file"
      attr :content

      ...
    end

The Attributes API has three methods. `desc` describes the purpose of an
attribute, `key` defines an attribute that must be unique for all
instances of this Pattern, and `attr` defines a simple variable.

Pass a second argument to `attr` or `key` to set a default value.

    attr :content, "Hello"

**Important** All attributes of a pattern must have a value. If nil is
an acceptable value, you must set that as the default.

#### Keys

A pattern's Key attributes describe what it means to be a unique
instance of a pattern. For example in our `File` example, the `path` is
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

## What is a Cluster

A Cluster is a set of Nodes that work together. The simplest way to use
clusters is to create multiple instances of your application (typically
called an 'environment'). Besides acting as a grouping mechanism, a
Cluster allows configuration of your blueprints. Cluster definitions are
stored in `clusters/[name].rb`

    $ config-create-cluster production
    $ vim clusters/production.rb
    configure :web,
      host: "example.com",
      enabled: true

Here we have created a `production` cluster and configured some
variables dealing with "web". When a Blueprint executes within this
Cluster, it may access variables to alter its behavior. You may define
as many sets of variables as you'd like. If you execute a pattern the
tries to access a variable that is not defined, Config will throw an
error.

    $ vim blueprints/webserver.rb
    add Nginx::Site do |site|
      site.host = cluster.web.host
      site.enabled = cluster.web.enabled
    end

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

### Nodes

A cluster is only useful once nodes are running within it. Each node has
access to the configuration of other nodes within its cluster, and
*only* within its cluster. You need not fear creating a staging cluster
whose configuration points to the production database.

To access facts about another node in the cluster, you may perform
simple queries.

    node = cluster.find_node(MySQL::Server => { master: true })
    node.facts.public_ip

## What is a Hub

A Hub acts as the coordinator for nodes within a cluster. You'll
typically have one hub, but you could have a different one for each
cluster if desired. A hub only differs from any other checkout of your
project in a few ways. Most importantly, it is the place where your
secret keys are stored, so that they may be distributed to new nodes.

You may use a different key for each cluster. By default, we'll have
one key for everything, called "default".

    echo "shh" | config-store-secret [NAME]

The project and data git repositories are also passed from the hub to
nodes. By default, Config uses the project's origin to determine the
repos. If your project repo is `my-project.git` the data repo should be
named `my-project-data.git`. To use different repos, specify them in
`hub.rb`.

If you want to use the same ssh key for both repos, this configuration
should suffice.

    $ vim hub.rb
    project_repo 'git@github.com:rcarver/config-example.git'
    data_repo    'git@github.com:rcarver/config-example-data.git'

If you wish to use a different key for each repo (GitHub deploy keys for
example), this form will allow you to specify the details.

    project_repo do |p|
      p.repo = 'git@github-project:rcarver/config-example.git'
      p.hostname = 'github.com'
      p.ssh_key = 'project'
    end
    data_repo do |p|
      p.repo = 'git@github-data:rcarver/config-example-data.git'
      p.hostname = 'github.com'
      p.ssh_key = 'data'
    end

The resulting `.ssh/config` looks something like this.

    Host github-project
      User git
      Hostname github.com
      IdentityFile /etc/config/ssh-key-project
    Host github-data
      User git
      Hostname github.com
      IdentityFile /etc/config/ssh-key-data

### Bootstrap

To allow a node to manage itself it must be boostrapped. Bootstrapping
installs system requirements, installs the secret and clones the git
repos. To bootstrap any server, run the bootstrap script (written in
bash) on it. To generate a bootstrap script, identify the cluster,
blueprint and a unique name for the node. We call this name the "FQN"
(fully qualified name). Here we bootstrap a new production webserver,
called "1".

    config-create-bootstrap production-webserver-1 | ssh IP_ADDRESS "sudo bash"

That's it. When the script completes the server will have a functional
copy of the project and will have added itself to the database (the
"data" repo). To see information about the new node, ask for it.

    config-show-node production-webserver-1

Behind the scenes, Config will sync the data repo and then extract node
facts and other information. You can see the raw data stored at
`.data/project-data/nodes/production-webserver-1.json`.

## Advanced Configuration

Following are more advanced ways to use Config. You can probably do a lot
without these techniques.

### Extending a Pattern

At times you may need to further extend an existing Pattern. For example, Our
`Nginx::Service` pattern is a high level service. It install Nginx and then
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
* Create nodes. Should they be stored or referenced by a "branch"
  pointer in the data repo?
* Merging this to master would be weird, right?
* Should a Cluster indicate the branch(es) that are valid to boot from?
* Is this how one might do development?

## Reference

A brief overview of Config's APIs and tools.

### The Hub API

DSL for `hub.rb`.

* `project_repo` Set the git url for the project.
* `data_repo` Set the git url for the project data.

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
