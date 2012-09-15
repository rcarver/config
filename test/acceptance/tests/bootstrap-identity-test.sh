#!/usr/bin/env roundup
# test: config/bootstrap/templates/identity.erb

describe "Bootstrap determines the node identity"

it_sets_the_hostname() {
  hostname="$(hostname)"
  test "$hostname" = "vagrant-devbox-acceptance"
}

it_permanently_sets_the_hostname() {
  hostname=$(cat /etc/hostname)
  test "$hostname" = "vagrant-devbox-acceptance"
}

it_sets_the_fqdn_in_etc_hosts() {
  line=$(tail -n1 /etc/hosts)
  # TODO: how to match:
  # ip.address <fqdn> <fqn>
}

it_stores_the_secret() {
  test -f /etc/config/secret
  # TODO: should we check the content?
}

it_secures_the_secret() {
  mode=$(stat -c %a /etc/config/secret)
  test $mode = 600
}
