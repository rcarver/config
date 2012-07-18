# SSH

If you have a complex git/ssh setup, read on.

## Same domain, different keys

If your project and database repos are hosted at the same place, but
require separate SSH keys to access, we need a tricky ssh config. Your
settings might look something like this.

    configure :project_git_repo,
      repo: 'git@github-project:rcarver/config-example.git',
      hostname: 'github.com',
      ssh_key: 'project'

    configure :database_git_repo,
      repo: 'git@github-data:rcarver/config-example-data.git'
      hostname: 'github.com'
      ssh_key: 'database'

Generate and store the two ssh keys.

    cat ~/.ssh/id_rsa_project | config-store-ssh-key project
    cat ~/.ssh/id_rsa_database | config-store-ssh-key database

The resulting `.ssh/config` looks something like this.

    Host github-project
      User git
      Hostname github.com
      IdentityFile /etc/config/ssh-key-project
    Host github-data
      User git
      Hostname github.com
      IdentityFile /etc/config/ssh-key-database


