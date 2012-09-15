# Acceptance Tests

This directory contains a full-stack acceptance test. This test involves
creating a fresh Config project, adding some patterns and then booting a
Vagrant box. That box is bootstrapped and then provisioned using the
project. After provisioning, a set of tests are run against the box to
ensure that Config put it into the expected state.

There are a handful of scripts that make this go.

  * `clean` Clean up an existing project, including shutting down its
    vagrant box.
  * `build` Build a new project at `/tmp/config-test-project` This
    project is all set up to boot a Vagrant box and try out some new stuff.
  * `boot` Bootstrap and run config on a Vagrant box.
  * `test` Run tests that verify that the bootstrap and config execution
    put the system into the expected state. These tests are run by the
    amazing [roundup](http://bmizerany.github.com/roundup/) and stored
    in `test/acceptance/tests`.
  * `run` Does all of these things to perform a complete end-to-end
    test.

The tests use your current codebase to execute against, so it's a great
way to try things out in real time.

