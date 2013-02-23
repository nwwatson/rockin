require "bundler/capistrano"
load 'deploy/assets'

server "<%= ip %>", :web, :app, :db, primary: true

# Deployment Settings
set :application, "<%= application %>"
set :domain, "#{application}.com"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :port, 22
set :default_environment, {
  'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
}
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

# Firewall SSH Port (You'll need to change the port above if you set a different port during deploy:install)
set :ssh_port, 22

# NGINX Settings
set :nginx_multiple_sites, true # Set false if this is the only site bound to an IP

# Datbase Settings
#set :database, "mysql"
set :database, "postgresql"

# Git Repository Settings
set :scm, "git"
set :repository, "<%= git_url %>"
set :branch, "master"


default_run_options[:pty] = true
ssh_options[:forward_agent] = true

require 'rockin/recipes/base'
require 'rockin/recipes/check'
require 'rockin/recipes/nginx'
require 'rockin/recipes/nodejs'
require "rockin/recipes/#{database}"
require 'rockin/recipes/rbenv'
require 'rockin/recipes/unicorn'
require 'rockin/recipes/utilities'
require 'rockin/recipes/security'

after "deploy", "deploy:cleanup" # keep only the last 5 releases
