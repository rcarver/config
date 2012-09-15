#!/usr/bin/env roundup
# test: config/bootstrap/templates/access.erb

describe "Bootstrap sets up ssh access"

it_creates_ssh_config() {
  test -f /root/.ssh/config
  # TODO: the .ssh/config is empty right now. We should set up the test project
  # to require some ssh setup.
}

it_secures_ssh_config() {
  mode=$(stat -c %a /root/.ssh/config)
  test $mode = 600
}

it_installs_known_hosts() {
  test -f /root/.ssh/known_hosts
  # TODO: the .ssh/config is empty right now. We should set up the test project
  # to require some ssh setup.
}

it_secures_known_hosts() {
  mode=$(stat -c %a /root/.ssh/known_hosts)
  test $mode = 600
}

it_installs_ssh_keys() {
  # TODO: the .ssh/config is empty right now. We should set up the test project
  # to require some ssh setup.
  true
}
