#!/usr/bin/env roundup
# test: config/bootstrap/templates/system.erb

describe "Bootstrap installs useful software"

ruby_version="1.9.3-p194"

it_installs_git() {
  test -n $(which git)
}

it_installs_curl() {
  test -n $(which curl)
}

it_installs_ruby() {
  test -x /opt/ruby-config-${ruby_version}/bin/ruby
  test -n "$(config-ruby -v)"
}

it_installs_bundler() {
  test -x /opt/ruby-config-${ruby_version}/bin/bundle
  test -n "$(config-bundle -v)"
}
