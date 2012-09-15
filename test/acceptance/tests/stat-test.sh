#!/usr/bin/env roundup
# test: fixtures/stat.rb

describe "Files and directories have the correct owner, group and mode"

it_sets_mode_on_file() {
  mode=$(stat -c %a /tmp/test-file-chmod)
  test $mode = 777
}

it_sets_mode_on_dir() {
  mode=$(stat -c %a /tmp/test-dir-chmod)
  test $mode = 1777
}

it_sets_owner_on_file() {
  owner=$(stat -c %U /tmp/test-file-chown)
  group=$(stat -c %G /tmp/test-file-chown)
  test $owner = vagrant
  test $group = admin
}

it_sets_owner_on_dir() {
  owner=$(stat -c %U /tmp/test-dir-chown)
  group=$(stat -c %G /tmp/test-dir-chown)
  test $owner = vagrant
  test $group = admin
}
