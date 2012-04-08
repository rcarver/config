# Config (a working title)

A modern server maintenance tool.

## Goals

* Simple and minimal interface and implementation. No magic.
* A clear and obvious way to do things.
* An API and supporting tools that naturally reduces errors.
* Useful information when things do go wrong.
* Git-native change management for all aspects of the system
* Supports branching for development.

## Concepts

* __Node__ A server. A Node has a Blueprint and belongs to a Cluster.
* __Blueprint__ The complete set of Patterns that describe a Node.
* __Cluster__ A collection of Nodes that work together.
* __Pattern__ A reusable concept that makes up a Blueprint or another Pattern. All Patterns operations are idempotent.
* __Fact__ A bit of information about a Node that cannot be changed such as memory or IP address.
* __Variable__ A part of a Blueprint that may be changed. Variables may be set on either the Node or Blueprint.
* __Service__ A long running application, generally managed by Upstart. A Service may be notified that something it depends on has changed, when that happens the Service typically restarts.
* __TODO__ is monitoring/alerting a core concept?

### Patterns

Config comes with a set of useful Patterns built in. These Patterns form the
building blocks for your own higher level Patterns and the Blueprints that use
them.

* __Directory__ A directory on disk.
* __File__ A file on disk. The contents may come from an ERB template, or a string.
* __Link__ A symbolic (or hard) link.
* __Package__ Install a 3rd party library via apt
* __Script__ Any executable code.

## Basic Use

Config stores everything in a git repository. And by everything we mean both
the Patterns and Blueprints that describe how we want a Node to behave, and the
Nodes themselves.

To generate a new project

    $ config create myproject
    $ cd myproject

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
      [cluster]_[node_id].rb

To create a new server, begin by creating a Blueprint

    $ vim blueprints/webserver.rb

    it "Configures a server to run example.com"

    add Nginx::Service
    add Nginx::Site do |site|
      site.host = "example.com"
      site.enabled = true
    end

This Blueprint uses two Patterns. Those Patterns might look something like this

    $ vim patterns/nginx/service.rb

    module Nginx
      class Service < Config::Pattern

        it "Installs nginx and creates a service to run it"

        desc "The name of the service to run"
        attr :name, "nginx"

        def call
          package "nginx"
          file "/etc/nginx/nginx.conf" do |f|
            f.template = "nginx.conf"
          end
          service name
          notify name
        end
      end
    end

    $ vim patterns/nginx/site.rb

    module Nginx
      class Site < Config::Pattern

        it "Installs a website to be hosted via nginx"

        desc "The hostname that the site should respond to"
        attr :host

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
    end

Next we'll create a Cluster to contain the server. Let's call it 'test'.

    $ vim clusters/test.rb

    # nothing to see here yet.

Check these files into git and push to your remote repository. You're now ready
to boot a server.

    $ config node-create-ec2 --pattern=webserver --cluster=test

Here we've specified the two required parameters: The Pattern used to configure
the server, and the Cluster that the resulting Node will belong to. We wait for
AWS to provision us a server, and once the server boots it will automatically
configure itself and store its information in this git repo. Once those commits
exist, pull them down. Use the `--wait` flag to let Config do that for you.

    $ git pull

    + clusters/test/[node_id].json
    + facts/test_[node_id].json

Let's look at the facts first. This JSON file contains all kinds of information
inherent to the server itself.

    $ cat facts/test_[node_id].json

    { "ec2.instance_id": "i-91923", "ip_address": "127.0.0.1", ... }

On the other hand, `clusters/test/[node_id].json` is completely empty. That's
ok. We can use this file to customize the way that this particular Node
behaves. See Variables for more information.

## Testing

Because developing and testing against a real server is slow, Config provides
several tools to help you understand what will happen before you get there.

### Validate

Config can validate that your files are well formed and that all required
variables have been specified.

    $ config validate

If something is invalid, Config will tell you.

    blueprints/test.rb
    Nginx::Site missing value for :name (The hostname that the site should respond to)

    patterns/nginx/service.rb
    Nginx::Service missing description for attribute :name

### Try a Blueprint

Once the parts are valid, you might want to get an idea of what the result of a
Blueprint will be.

    $ config try blueprints/test.rb

The result of this command is a record of everything that would happen. It might look
something like this, showing the hierarchy of patterns used and their results.

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

## What is a Pattern

A Pattern is a reusable bit of configuration. Patterns are composable,
and so therefore may be of any size and scope. Low level patterns such
as `File` and `Package` are provided by Config. You can use these
patterns to create your own, higher level patterns.

### The Pattern API

All patterns inherit from `Config::Pattern`. Your pattern must implement
at least two methods: `to_s` and `call`. A trivial example.

    class LastRunAt < Config::Pattern

      def to_s
        "Last Run At"
      end

      def call
        file "/etc/config_was_run" do |f|
          f.content = Config.boot_time.to_s
        end
      end
    end

This Pattern simply stores the last time that Config was run at
`/etc/config_was_run`. We defined `to_s` to describe the pattern
itself. This string is used extensivly when logging what Config has
done. We then defined `call` to use the builtin `File` pattern via the
`file` helper. To expose what's going on here, let's rewrite it without
the helper.

    def call
      add Config::Patterns::File do |f|
        f.path = "/etc/config_was_run"
        f.content = Time.now
      end
    end

With this we've exposed another important method in Pattern's API,
`add`. `add` takes a Pattern class and an optional configuration block.
More importantly, we've exposed that by instantiating a Pattern we have
not executed it. Put another way: there are two phases to using a
Pattern: Accumulation and Execution. To configure a server, obviously we
need to Execute the Pattern, but there are also many benefits of using
only the Accumulation phase.

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

**Important** All attributes of a Pattern must have a non-nil value. If
an attribute of your Pattern is optional, it must have a default value.

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

### Create & Destroy

The Pattern API has two additional methods: `create` and `destroy`. It's
rare that you will need to use them in most cases.

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

## Advanced Configuration

Following are more advanced ways to use Config. You can probably do a lot
without these techniques, but this is where it gets interesting.

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
* Create nodes
* Merging this to master would be weird, right?
* Should a Cluster indicate the branch(es) that are valid to boot from?
* Is this how one might do development?

## Authors

* Ryan Carver (ryan@ryancarver.com / @rcarver)

## License

Copyright 2012 Ryan Carver. Licensed under MIT.
