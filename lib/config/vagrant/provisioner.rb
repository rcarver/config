require 'config'

begin
  require 'vagrant'
rescue LoadError
  abort "Cannot load #{__FILE__} because vagrant is not installed"
end

module Config
  module Vagrant
    class Provisioner < ::Vagrant::Provisioners::Base

      class Config < ::Vagrant::Config::Base

        # Public: Set the name of the cluster. Defaults to "vagrant".
        attr_writer :cluster

        # Public: Set the name of the blueprint. Defaults to "devbox"
        attr_writer :blueprint

        # Public: Set the identity. Defaults to `ENV['USER']`.
        attr_writer :identity

        # Public: Set to true to force bootstrapping, even if it's
        # already been bootstrapped. Defaults to false, also settable
        # via `ENV['BOOTSTRAP']`
        attr_writer :bootstrap

        def cluster
          @cluster || "vagrant"
        end

        def blueprint
          @blueprint || "devbox"
        end

        def identity
          @identity || ENV['USER']
        end

        def bootstrap
          @bootstrap || ENV['BOOTSTRAP'] || false
        end
      end

      def self.config_class
        Config
      end
      
      def provision!
        bootstrap_marker = "/etc/config/vagrant-bootstrapped"

        # TODO: throw Vagrant::Errors::VagrantError instead of aborting.
        # 1. We need to add i18n translations
        # 2. We need to rework CLI error handling to make it possible to
        #    throw error keys instead of messages.

        # Determine if this box has been bootstrapped.
        bootstrapped = env[:vm].channel.test("test -f #{bootstrap_marker}")

        if config.bootstrap || !bootstrapped

          stdin, stdout, stderr = [StringIO.new, StringIO.new, StringIO.new]
          cli = ::Config::CLI.new("config-create-bootstrap", stdin, stdout, stderr)
          cli.run([config.cluster, config.blueprint, config.identity], {})

          buffer_output(stdout.string)

          env[:vm].channel.sudo("touch #{bootstrap_marker}")
        else
          buffer_output("config-run")
        end
      end

    protected

      def buffer_output(script)
        buffer = ""
        env[:vm].channel.sudo(script) do |s, data|
          buffer << data
          if buffer =~ /\n/
            env[:ui].info buffer.chomp, :prefix => false
            buffer = ""
          end
        end
      end

    end
  end
end
