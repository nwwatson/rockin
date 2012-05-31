# Rockin

Capistrano tasks for deploying Rails applications using Ubuntu 10.04, rbenv, nginx, Unicorn and PostgreSQL or MySQL. Much of the code has been taken from Ryan Bates's [Capistrano Recipes](http://railscasts.com/episodes/337-capistrano-recipes) Screencast. It is highly recommended that you view the screencast for further information on Capistrano deployment recipes.

## Requirements

* Capistrano
* Fresh Ubuntu 10.04 or 11.10 install

## Installation

Add these lines to your application's Gemfile:

    gem 'capistrano'
    gem 'unicorn'
    gem 'rockin', :git => 'git@github.com:entropillc/rockin.git'

And then execute:

    bundle install

## Usage

In your project, run the following:

    capify .

Then run this generator with an optional IP address to copy over a deploy.rb that is more suited to this gem.
The application name defaults to the same name as your rails app and the repository is pulled from your .git/config.

    rails g rockin:install 99.99.99.99
    
Once the command is run, it might ask you for permission to overwrite deploy.rb. Say yes.

Before you run any Commands, its is recommended that you do not use the root account for your VPS with the scripts. You must create yourself a user within the administrative group. To do this, on the VPS, run the following command:

    adduser <username> --ingroup admin
    
Replace <username> with the username of your choice.
  
This script is able to setup both mysql and postgres databases. To change the database which you want installed, edit the following line in the config/deploy.rb file:

    set :database, "mysql" # or "postgresql"
    
Double check the settings in the deploy.rb file. Play close attention to the values for server, domain, application and repository to ensure the are correct.

You can start package installation on Ubuntu by running the following command. This will install all the necessary packages run you application

    bundle exec cap deploy:install
    
To set up the deployment directories for your application and setup a blank database, run the following command.

    bundle exec cap deploy:setup
    
When you are ready to deploy your code, run the following command:

    bundle exec cap deploy:cold

## Advanced Options

Shown below are the default advanced settings, but they can overridden.

### Setup

    set(:domain) { "#{application}.com" }

### Ruby

    set :ruby_version, "1.9.3-p125"
    set :rbenv_bootstrap, "bootstrap-ubuntu-10-04" # Or bootstrap-ubuntu-11-10

### Unicorn

    set(:unicorn_user) { user }
    set(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
    set(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
    set(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
    set :unicorn_workers, 2

## Found a bug?

If you are having a problem with Bootstrapped, first look at the FAQs above. If you still cannot resolve it, please submit an issue here.

http://github.com/entropillc/rockin/issues

## Contribute

Contributing is simple, [create an issue](http://github.com/entropillc/rockin/issues) to ensure that your change will be accepted. Then fork the repo, create a branch, make your change, and submit a pull request attaching your code to the issue.



