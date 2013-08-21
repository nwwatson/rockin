require "bundler/capistrano"
load 'deploy/assets'

server "<%= ip %>", :web, :app, :db, primary: true

# Deployment Settings
set :application, "<%= application %>"
set :domain, "#{application}.com"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, <%= app_server.eql?("trinidad") ? ':copy' : ':remote_cache' %>
<% if app_server.eql?("trinidad") -%>
set :copy_exclude, %w[.git log tmp .DS_Store]
<% end -%>
set :use_sudo, false
set :port, 22
set :default_environment, {
  'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
}
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

# Git Settings
<% if app_server.eql?("trinidad") -%>
set :repository, "."
set :scm, :none
<% else -%>
set :scm, "git"
set :repository, "<%= git_url %>"
set :branch, "master"
<% end -%>

# Firewall SSH Port (You'll need to change the port above if you set a different port during deploy:install)
set :ssh_port, 22

# NGINX Settings
set :nginx_multiple_sites, true # Set false if this is the only site bound to an IP
set :nginx_app_server, "<%= app_server %>"

# Datbase Settings
#set :database, "mysql"
set :database, "postgresql"

# Update Timezone. Turn off on AWS
set :timezone, true

# Ruby Settings
<% if options.jruby? -%>
set :jruby, true
set :ruby_version, "jruby-1.7.4"
<% else %>
set :ruby_version, "2.0.0-p195"  
<% end -%>

default_run_options[:pty] = true
<% unless app_server.eql?("trinidad") -%>
ssh_options[:forward_agent] = true
<% end -%>

require 'rockin/recipes/base'
<% unless app_server.eql?("trinidad")  -%>
require 'rockin/recipes/check'
<% end -%>
require 'rockin/recipes/nginx'
require "rockin/recipes/#{database}"
require 'rockin/recipes/rbenv'
<% unless app_server.eql?("trinidad")  -%>
require 'rockin/recipes/nodejs'  
<%  end -%>
require 'rockin/recipes/<%= app_server %>'
require 'rockin/recipes/utilities'
require 'rockin/recipes/security'

after "deploy", "deploy:cleanup" # keep only the last 5 releases
