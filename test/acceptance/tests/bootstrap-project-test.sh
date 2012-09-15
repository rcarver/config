#!/usr/bin/env roundup
# test: config/bootstrap/templates/project.erb

describe "Bootstrap installs the project"

it_cloned_the_project() {
  test -d /etc/config/project/.git
}

it_installs_config_scripts() {
  scripts=$(cd /usr/local/sbin && ls config-* | tr "\n" " ")
  test "${scripts}" = "config-disable config-enable config-run config-run-now config-run-protected "
}
