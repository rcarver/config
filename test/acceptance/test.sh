#!/bin/bash

set -x
set -e

# The current version of ruby.
rbenv_version=`rbenv version | awk '{ print $1 }'`

# The code under test.
config_dir=`pwd`

# A place to test the code.
project_dir=/tmp/config-test-project
database_dir=/tmp/config-test-database

# A place to store the test code.
project_repo_dir=/tmp/config-test-project-repo
database_repo_dir=/tmp/config-test-database-repo

# Initialize the test repos.
for dir in $project_repo_dir $database_repo_dir; do
  [ -d $dir ] && rm -rf $dir
  mkdir $dir
  cd $dir && git init --bare
done

# Initialize the test project directory.
[ -d $project_dir ] && rm -rf $project_dir
mkdir $project_dir
cd $project_dir

# Ensure we are using the right version of ruby.
rbenv local $rbenv_version

# =============================================================================
# Begin testing config.
# =============================================================================

# Initialize directory.
git init
bundle init

# Install dependencies
echo "gem 'config', :path => '$config_dir'" >> Gemfile
echo "gem 'vagrant'" >> Gemfile
bundle install --binstubs

# Initialize config.
bin/config-init-project

# Check in and push to git origin.
git add .
git commit -m 'initial comit'
git remote add origin $project_repo_dir
git push -u origin master

# Create a blueprint.
bin/config-create-blueprint webserver
git add blueprints/webserver.rb
git commit -m 'create webserver blueprint'

# Create a cluster.
bin/config-create-cluster prod
git add clusters/prod.rb
git commit -m 'create prod clsuter'

# Test that we can create a bootstrap script before firing up Vagrant.
bin/config-create-bootstrap prod webserver 1 > /dev/null

# Initialize Vagrant.
echo '
require "config/vagrant/provisioner"
Vagrant::Config.run do |config|
  config.vm.box = "base"
  config.vm.provision Config::Vagrant::Provisioner do |config|
    config.blueprint = "webserver"
    config.cluster   = "prod"
    config.identity  = "1"
  end
end
' > Vagrantfile

git add Vagrantfile
git commit -m 'add Vagrantfile'

# Boot the vagrant vm and config will provision it.
bin/vagrant up
trap "bin/vagrant destroy" EXIT




