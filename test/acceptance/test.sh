#!/bin/bash

# http://fvue.nl/wiki/Bash:_Error_handling
set -o errtrace
set -o nounset
set -x

# Trap certain errors on exit.
trap onexit 1 2 3 15 ERR

# Clean up files by default.
CLEANUP=1

# Call this to clean up a file at exit.
function cleanup() {
  local file=${1}
  trap "cleanup_at_exit $1" EXIT
}

# At exit, this will remove files marked for cleanup if we still want to
# do that.
function cleanup_at_exit() {
  local file=${1}
  if [ $CLEANUP ]; then
    echo Cleaning up $file
    #rm -rf $file
  else
    echo Keeping $file
  fi
}

# Catch exit and decide whether or not to cleanup files.
function onexit() {
    local exit_status=${1:-$?}
    if [ $exit_status -ne 0 ]; then
      CLEANUP=''
    fi
    echo Exiting $0 with $exit_status
    exit $exit_status
}

# The current version of ruby.
rbenv_version=`rbenv version | awk '{ print $1 }'`

# The code under test.
local_config_dir=`pwd`

# A place to test the code on the local machine.
project_dir=/tmp/config-test-project
database_dir=/tmp/config-test-database

# Everything that's accessed on both the local and remote system needs
# to be mapped into the VM. Storing these under /tmp lets us use the
# same path on both machines.
project_repo_dir=/tmp/config-test-project-repo
database_repo_dir=/tmp/config-test-database-repo
config_dir=/tmp/config

# Symlink the codebase to the shared directory.
ln -sf $local_config_dir $config_dir
cleanup $config_dir

# Initialize the test repos.
for dir in $project_repo_dir $database_repo_dir; do
  [ -d $dir ] && rm -rf $dir
  mkdir $dir
  cleanup $dir
  cd $dir && git init --bare
done

# Initialize the test project directory.
[ -d $project_dir ] && rm -rf $project_dir
mkdir $project_dir
cleanup $project_dir
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
bundle install --binstubs --local

# Check in and push to git origin.
git add .
git commit -m 'initial comit'
git remote add origin $project_repo_dir
git push -u origin master

# Initialize config.
bin/config-init-project

git add .
git commit -m 'initialize config'

# Patch config.rb so that the database repo is correct. We create better
# defaults when it's a remote repo so we'll deal with this annoyance for
# now. In reality it's normal for users to edit config.rb so this isn't
# the worst thing.
echo '
8c8
<   url: "/tmp/config-test-project-repo"
---
>   url: "/tmp/config-test-database-repo"
' | patch --force config.rb -

git add config.rb
git commit -m 'set database repo'

# Create the default blueprint.
bin/config-create-blueprint devbox
git add blueprints
git commit -m 'create devbox blueprint'

# Create a cluster.
bin/config-create-cluster vagrant
git add clusters
git commit -m 'create vagrant cluster'

# Store a secret.
echo 'shhhhh' | bin/config-store-secret

# Test that we can create a bootstrap script before firing up Vagrant.
bin/config-create-bootstrap vagrant devbox 1 > /dev/null

# Initialize Vagrant.
(
cat <<-STR
require "config/vagrant/provisioner"
Vagrant::Config.run do |config|
  config.vm.box = "base"
  config.vm.share_folder "config-code", "$config_dir", "$config_dir"
  config.vm.share_folder "project-repo", "$project_repo_dir", "$project_repo_dir"
  config.vm.share_folder "database-repo", "$database_repo_dir", "$database_repo_dir"
  config.vm.provision Config::Vagrant::Provisioner
end
STR
) > Vagrantfile

git add Vagrantfile
git commit -m 'add Vagrantfile'

# Push to the remote so we can execute the project.
git push

# Boot the vagrant vm and config will provision it.
#bin/vagrant up
#trap "bin/vagrant destroy --force" EXIT

# Ensure that we exit cleanly.
onexit

