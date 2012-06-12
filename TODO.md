# TODO

This document captures various ideas and notes that have not been
implemented yet.

## Extending a Pattern

At times you may need to further extend an existing Pattern. For example, Our
`Nginx::Service` pattern is a high level service. It install Nginx and then
uses Upstart to run it. Say we like this pattern, but need to more carefully
control when the underlying Upstart service starts. Use the `intercept` method
to tap that Upstart service and change its configuration.

    add Nginx::Service do |nginx|
      nginx.intercept Config::Patterns::Upstart do |upstart|
        upstart.start_on = "some event"
      end
    end

## Branch-based development

Something here about a workflow like this:

  * Create a new branch
  * Make changes to patterns, etc
  * Create nodes. Should they be stored or referenced by a "branch"
    pointer in the data repo?
  * Merging this to master would be weird, right?
  * Should a Cluster indicate the branch(es) that are valid to boot from?
  * Is this how one might do development?


