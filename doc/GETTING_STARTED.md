# Getting Started with Config

Config aims to make getting started as easy as possible. That said,
there are number of pieces to put into place before things get fun. This
document details exactly what you need to do and why. After finishing
this guide, you'll be ready to use Config to manage your servers.

#### System dependencies

Config requires git, ruby 1.9.3 and bundler. You'll need to have these
minimum dependencies in order to create a Config project.

    # Install git
    # Install ruby 1.9.3 or above.
    gem install bundler

## Create the project repo

The first step is to create your Config project. In a nutshell, the
project repository is when you write code. When you commit and push it
to the master branch, it will execute on your servers.

    # A working directory.
    mkdir myproject
    cd myproject
    git init

    # Initialize a bundler project.
    bundle init

    # Depend on config and install dependencies.
    echo 'gem "config", :git => "git@github.com:rcarver/config.git"' >> Gemfile
    bundle install --binstubs

    # Initialize your config project.
    bin/config-init-project

Check in the files and push it to a remote repository. If you're using
GitHub, first create a repository in your account and use the repo ssh
url that GitHub provides.

    git add .
    git commit -m 'initial comit'
    git remote add origin <repo ssh url>
    git push -u origin master

By the way, `config-init-project` is written in Config. The output it
generated is just like what you'll see when you execute your patterns.

## Create the data repo

Config uses a second repository to store the state of your system. This
provides a change-by-change history of everything that has happened.
Typically, this repository is called `myproject-data`. Go ahead and
create this second remote repository. Once it's created, config will
manage it for you.

## Designate a "hub"

The "hub" of your project is a machine that can bootstrap other
machines. In order to bootstrap a machine, it must have access to some
sensitive information. This information is one of the few things that
are *not* stored in the git repositories. Instead, Config manages files
within `.data`, which is ignored by git.

The easiest way to get started is to use your development machine as the
hub. We can easily make a remote machine the hub at another time. Doing
so allows us to use things like AWS AutoScale. For the time being, we'll
focus on the basics and create servers one at a time.

### Store the git ssh key

In order for Config to access your git repos from remote servers, we
need to give it an ssh key. To do that, pipe your *private* key to
`config-store-ssh-key`. This key *must* have no passphrase.

    cat ~/.ssh/id_rsa | bin/config-store-ssh-key

The result is a copy of your ssh key stored at
`.data/ssh-key-default`. See [GIT](GIT.md) If you require different
keys for the project and data repos. See [GITHUB](GITHUB.md) for
specifics on how to best manage repos, users and keys at GitHub.

### Know your hosts

In order for a fresh server to trust the host serving our git repos, we
need to generate entries for the `known_hosts` file.

    bin/config-know-hosts

The result of this is a file in `.data` for each host we'll need to
access during bootstrapping. In this example, if your repos are stored
at GitHub, we'd have created the file `.data/ssh-host-github.com`. See
[SSH](SSH.md) for more information.

### Store a secret

So that we can store sensitive information securely in our project repo,
config uses a secret to encrypt and decrypt that information at runtime.

    # TODO: how to generate a secret?

To store a secret, pipe it to `config-store-secret`.

    cat $secret_file | bin/config-store-secret

The result is a copy of your secret stored at `.data/secret-default`.
See [SECRETS](SECRETS.md) to learn about using more than one secret.

## Create a blueprint

A blueprint is the template for managing a server. To begin configuring
a webserver, let's create a `webserver` blueprint.

    bin/config-create-blueprint webserver

The result is a file at `blueprints/webserver.rb`. We can leave the
file empty for now. Check this file in and `git push`.

## Create a cluster

A cluster is the environment in which a blueprint, and the resulting
node, live. Let's create a `production` cluster.

    bin/config-create-cluster production

The result is a file at `clusters/production.rb`. We can leave this
file empty for now. Check this file in and `git push`.

## Bootstrap a node

We're now ready to manage a server with Config. To bootstrap a server,
we must specify the `cluster`, the `blueprint` and a unique `identity`
for the node. The identity must be unique for other nodes with the same
cluster and blueprint. By convention we'll call the node `1` and
generate a bootstrap script.

    bin/config-create-bootstrap production webserver 1

The result of this command is a bash script written to STDOUT. That
doesn't do a lot of good, but you might find it interesting to inspect
it. Instead, what we need to do is run that script on a fresh server.
The simplest way to do that is to pipe it over ssh.

**Not covered here** is how to create a fresh server. We'll continue
assuming you have created a new machine and can ssh to it using
`$hostname` See [SSH](SSH.md) for tips on ssh configuration.

    bin/config-create-bootstrap production webserver 1 \
      ssh $hostname 'sudo bash'

This command generates a bootstrap script, then executes it on the
remote server as root. Once it finishes we have:

1. A fully functional Config node. The node can be updated at any time
   by ssh'ing to it and executing `config-run`.
2. The first node in our system. It's called `production-webserver-1`
   and has a FQDN of `production-webserver-1.internal.example.com`.
3. An entry in the data repo. Whenever a node is updated via
   `config-run`, it stores its state in the data repo.

Back at the hub, try running

    bin/config-show-node production-webserver-1

The result is a (large) JSON blob containing
[Ohai](http://wiki.opscode.com/display/chef/Ohai) data. To filter that
data down, pass a path to the structure you'd like to see.

    bin/config-show-node production-webserver-1 kernel
    bin/config-show-node production-webserver-1 kernel.version
    bin/config-show-node production-webserver-1 ec2
    bin/config-show-node production-webserver-1 ec2.public_ipv4

What's happening here? Config pulls down the latest data repo (stored in
`.data/project-data`) and then reads the contents of
`project-data/nodes/production-webserver-1.json`.

## For real this time

That's it. Everything is set up and ready to be customized. We can start
configuring our webserver to serve content.

### Next up

Learn about core concepts.

* [BLUEPRINT](BLUEPRINT.md) Learn how blueprints can describe the entire
  state of a server.
* [CLUSTER](CLUSTER.md) Learn about how clusters group nodes and
  configure blueprints.
* [NODE](NODE.md) Learn about managing and configuring nodes.
* [WORKFLOW](WORKFLOW.md) Learn how to write, test and execute changes
  to your configuration.

Get details for configuring Config.

* [HUB](HUB.md) Learn about managing a hub and configuring a few
  centralized aspects of Config.
* [GIT](GIT.md) Details about how git is used and configured. For
  example, how did Config know where the data repo lives?
* [GITHUB](GITHUB.md) Tips and techniques for storing Config repos at
  GitHub.
* [SSH](SSH.md) Additional information on ssh issues.
* [SECRETS](SECRETS.md) Tips on generating and using secrets

