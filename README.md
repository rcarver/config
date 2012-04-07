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
* __Pattern__ A reusable concept that makes up a Blueprint or another Pattern. A Pattern supports at least two operations: `create` and `destroy`. All Patterns operations are idempotent.
* __Fact__ A bit of information about a Node that cannot be changed such as memory or IP address.
* __Variable__ A part of a Blueprint that may be changed. Variables may be set on either the Node or Blueprint.
* __Service__ A long running application, generally managed by Upstart. A Service may be notified that something it depends on has changed, when that happens the Service typically restarts.
* __TODO__ is monitoring/alerting a core concept?`

### Patterns

Config comes with a set of useful Patterns built in. These Patterns form the 
building blocks for your own higher level Patterns and the Blueprints that use 
them.

* __File__ A file on disk. The contents may come from an ERB template, a static string or the output of a script.

        create: Create and/or update the attributes of the file on disk
        destroy: Remove the file from disk

* __Directory__ A directory on disk.

        create: Create and/or update the attributes of the directory on disk.
        destroy: Remove the directory from disk.
    
* __Link__ A symbolic (or hard) link.

        create: Create the link.
        destroy: Delete the link.

* __Script__ Any executable code.

        create: Run the code
        destroy: Noop

* __Service__ An upstart service that starts and stops something

        create: Start the service if it is not running
        destroy: Stop the service if it is running
        notify: Start or restart the service

* __Package__ Install a 3rd party library via apt

        create: Install the package
        destroy: Uninstall the package

## Basic Use

Config stores everything in a git repository. And by everything we mean both 
the Patterns an Blueprints that describe how we want a Node to behave, and the 
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
          link "/etc/nginx/sites-available/#{host}" => "/etc/nginx/sites-enabled/#{host}" do |f|
            f.exists = enabled
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
