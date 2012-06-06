# Bootstrap

Bootstrap is the process of taking a fresh server and setting it up as a
Config [node](NODES.md). To do so requires a few steps.

  1. Install system dependencies such as git and ruby. This is the basic
     software that Config requires to run.
  2. Set up SSH keys and known hosts so that the node can clone the git
     repository.
  3. Set the identity of the node by setting its `hostname`.
  4. Install [secrets](SECRETS.md) so that the project can decrypt
     sensitive information.
  5. Git clone and install the project repository.
  6. Run config via `config-run`.

After bootstrapping, a server may be considered a [node](NODES.md). At
this point it may execute `config-run` at any point to execute the
latest project configuration or to update its information in the
database.

## Bootstrapping

To bootstrap a server, we first need a script to perform the above
steps. Config can create this script via
[`config-create-bootstrap`](../man/config-create-bootstrap.1.md).

    config-create-bootstrap production webserver 1

The result of this command is a bash script written to STDOUT. It
includes everything the server needs to get started.

The simplest way to bootstrap a server is to pipe this script over SSH.

    config-create-bootstrap production webserver 1 | ssh $HOST 'sudo bash'

See [SSH](SSH.md) for tips on configuring your ssh client to make this
easy.

## Idempotency

It's worth noting that the bootstrap process is idempotent. That is, you
may run the same bootstrap script on a server multiple times without
issue. If the script fails (either by misconfiguration or random network
error), simply run it again.

Likewise, to change any of the low level configuration such as ssh keys
or secrets, run the bootstrap script again.

On the other hand, it is *not* recommended to re-bootstrap a node with
another FQN. Doing so would effectively change the role of the server
and may have unintended effects (NOTE: this is currently conjecture and
should be tested).

