# Private Data

Private Data allows you to bootstrap new nodes.

  1. SSH keys
  2. SSH known hosts
  3. Secrets

Private Data is stored in your project's `.data` directory (and is
ignored by git). Config provides several tools to help manage this
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

