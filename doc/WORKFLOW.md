# Workflow

Your ability to safely and effectively alter live systems is critical.
Config has strong opininions on a workflow and development process that
will help.

TODO: write this document.

## Testing

Because developing and testing against a real server is slow, Config
provides several tools to help you understand what will happen before
you get there.

### Try a blueprint

Once the parts are valid, you might want to get an idea of what the
result of a Blueprint will be.

    $ config-try-blueprint webserver production

The result of this command is a record of everything that would happen
if a webserver executes within the production clsuter. It might look
something like this, showing the hierarchy of patterns used and their
results.

TODO: update with real log output.

    # Nginx::Service
      # Config::Patterns::Package
      Installed nginx
      # Config::Patterns::File
      Created /etc/nginx/nginx.conf
          user www;
          worker_processes 1;
          ...
      Set owner of /etc/nginx/nginx.conf to www
      # Config::Patterns::File
      Created /etc/init.d/nginx.conf
          ...
          exec /etc/nginx/bin/nginx -c /etc/nginx/nginx.conf
          ...
      Set owner of /etc/init.d/nginx.conf to root
      ...
    # Nginx::Site
      # Config::Patterns::File
      Created /etc/nginx/sites-available/example.com
          ...
      # Config::Patterns::Link
      Created /etc/nginx/sites-available/example.com => /etc/nginx/sites-enabled/example.com
    Notify nginx

You can also try a blueprint without specifying a cluster. Doing so uses
a "spy" cluster to collect all of the variables required to execute the
blueprint.

    $ config-try-blueprint production

TODO: provide sample spy output.
