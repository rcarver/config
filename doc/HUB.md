# Hub

The hub manages a few centralized aspects of a Config project.

  1. FQDN
  2. Git repos
  3. SSH keys
  4. SSH known hosts
  5. Secrets

With this information, the hub can create [bootstrap
scripts](BOOTSTRAP.md) that install this information on other servers.
Technically, any server that has this information could be considered a
hub. In practice you'll generally designate a single machine to act as
the hub. Your development workstation is a great first hub.

Hub configuration data is stored in two places.

  1. `hub.rb` This file may be safely checked into git.
  2. Files in `.data/*`. These files are excluded from git.

## FQDN

When a [node](NODES.md) is bootstrapped, its `hostname` is set to the
FQN of the node. Its FQDN is also set. That value is determined by
`hub.rb`.

By default, your `hub.rb` looks like this.

    domain "internal.example.com"
    
And nodes will have a FQDN of `$fqn.internal.example.com`. For example,
`production-webserver-1.internal.example.com`. Simply change the value
to set your nodes' FQDN to something more suitable.

**Note** at this time Config does not handle any other aspects of DNS
for you.

## Git repos

Config requires two git repositories: the project repo and the project
data repo. By default, Config will infer the remote location of these
repositories by looking the `origin` or your project checkout.

For example, given this git config

    cat .git/config
    ... snip ...
    [remote "origin"]
      url = git@github.com:rcarver/config-example.git
    ... snip ...

Config will infer this hub configuration

    project_repo 'git@github.com:rcarver/config-example.git'
    data_repo    'git@github.com:rcarver/config-example-data.git'

The data repo is expected to be located at the same remote location and
named "$project-data.git". If your repos follow this convention then you
do not need to specify them in `hub.rb`.

If your repos don't follow this convention **or** each require a different
SSH key, see [advanced setup](#advanced-setup).

## Sensitive information

Sensitive information is stored in your projects `.data` directory (and
is ignored by git). Config provides several tools to help manage this
information.

### SSH keys

In order to contact the git repos, we will need an ssh key. It's
recommended that you generate a key for use by Config. This key **must**
have no passphrase. Give Config the *private* key.

    cat ~/.ssh/id_rsa | config-store-ssh-key

The result of this command is a file written to `.data/ssh-key-default`.

### SSH known hosts

To ensure the authenticity of the hosts serving our git repos, we'll
pre-generate their `known_hosts` entries. 

    config-know-hosts

The result of this command is a file written to
`.data/ssh-host-$hostname` for each host used by Config. The files
contain the output of `ssh-keyscan`.

### Secrets

Config uses secrets to encrypt and decrypt all other sensitive
information. By doing this, we can safely and conveniently store things
like passwords and access tokens in our project repository.

TODO: how to generate a secret?

    echo "shh" | config-store-secret

The result of this command is a file written to `.data/secret-default`.

## Advanced setup

If you have a more complex git/ssh setup, read on.

### Same domain, different keys

If your project and data repos are hosted at the same place, but require
separate SSH keys to access, we need a tricky ssh config. Your `hub.rb`
might contain something like this.

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

Generate and store the two ssh keys.

    cat ~/.ssh/id_rsa_project | config-store-ssh-key project
    cat ~/.ssh/id_rsa_data | config-store-ssh-key data

The resulting `.ssh/config` looks something like this.

    Host github-project
      User git
      Hostname github.com
      IdentityFile /etc/config/ssh-key-project
    Host github-data
      User git
      Hostname github.com
      IdentityFile /etc/config/ssh-key-data

