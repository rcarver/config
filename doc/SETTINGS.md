# Settings

Settings are how you configure Config. Settings are defined via the same
mechanism as any configuration, and may be set globally, for a cluster
or for a node. In general, you'll define settings globally in
`config.rb`.

  1. FQDN
  2. Git repos

## FQDN

When a [node](NODES.md) is bootstrapped, its `hostname` is set to the
FQN of the node. Its FQDN is also set. That value is determined by
settings.

By default, your `config.rb` looks like this.

    configure :project_hostname,
      domain: "internal.example.com"

Nodes will have a FQDN of `$fqn.internal.example.com`. For example,
`production-webserver-1.internal.example.com`. Simply change the value
of `domain` to set your nodes' FQDN to something more suitable.

**Note** at this time Config does not handle any other aspects of DNS
for you.

## Git repos

Config requires two git repositories: the project repo and the database
repo. When you run `config-init-project`, reasonable values will be
stored in your `config.rb`. For example, given this git config.

    cat .git/config
    ... snip ...
    [remote "origin"]
      url = git@github.com:rcarver/config-example.git
    ... snip ...

Config will infer these settings.

    configure :project_git_repo,
      url: 'git@github.com:rcarver/config-example.git'

    configure :datbase_git_repo,
      url: 'git@github.com:rcarver/config-example-data.git'

## Reference

DSL for project settings.

  * `project_hostname`

        domain: Set the FQDN pattern for nodes.

  * `project_repo`

        url: Set the git url for the project.
        (and anything supported by ssh_configs)

  * `data_repo`

        url: Set the git url for the database.
        (and anything supported by ssh_configs)

  * `ssh_configs (repeated)

        host: The ssh host.
        user: The user to connect as.
        hostname: The hostname to contact.
        port: The port to connect to.
        ssh_key: The name of the ssh key to use.

Examples.

    # Nodes will be named <fqn>.internal.example.com
    configure project_hostname,
      domain: "internal.example.com"

    # Short form, uses the "default" ssh key.
    configure :project_git_repo,
      url: "git@github.com:rcarver/config-example.git"

    # Short form, uses the "default" ssh key.
    configure: database_git_repo,
      url: "git@github.com:rcarver/config-example-data.git"

    # Long form, specifying the complete ssh configuration.
    configure :project_git_repo,
      url: "github-project:rcarver/config-example.git",
      hostname: "github.com",
      user: "tig",
      port: 999,
      ssh_key: "project"

    # Another SSH configuration. Useful if your project has dependencies
    # that are stored in git and authorized by another key.
    configure :ssh_configs,
      url: "github:rcarver/dependency.git",
      hostname: "github.com",
      port: 999,
      ssh_key: "another"

