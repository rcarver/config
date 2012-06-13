# Config + Vagrant

[Vagrant](http://vagrantup.com/) is a great tool for building
and maintaining development VM's. You can use Config to provision and
maintain the state of your Vagrant box.

It's as simple as this.

    require 'config/vagrant/provisioner'
    Vagrant::Config.run do |config|
      config.vm.provision Config::Vagrant::Provisioner
    end

By default, this will provision a [node](NODES.md) named
`vagrant-devbox-<user>` where `<user>` is your unix username. This makes
it easy for every member of your team to get started with their own
node. To change that, specify what you'd like.

    require 'config/vagrant/provisioner'
    Vagrant::Config.run do |config|
      config.vm.provision Config::Vagrant::Provisioner do |config|
        config.cluster   = "development"
        config.blueprint = "webserver"
        config.identity  = "rcarver-2
      end
    end

The first time you provision a vagrant box, Config will run the full
bootstrap process. That means there's no need to install Config in your
base box. On subsequent runs, Config will run a standard update. To
re-bootstrap your box, set `bootstrap` in your provision config.

    config.vm.provision Config::Vagrant::Provisioner do |config|
      config.bootstrap = true
    end

Or, set an environment variable when you provision.

    BOOTSTRAP=1 bin/vagrant provision
