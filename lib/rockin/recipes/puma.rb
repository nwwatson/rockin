Capistrano::Configuration.instance(:must_exist).load do
  set_default(:puma_environment) { rails_env }
  set_default(:puma_bind) { "unix://#{shared_path}/sockets/puma.sock" }
  set_default(:puma_pid) { "#{shared_path}/pids/puma.pid" }
  set_default(:puma_state) { " #{shared_path}/sockets/puma.state" }
  set_default(:puma_config) { "#{shared_path}/config/puma.rb" }
  set_default(:puma_user) { user }

  namespace :rockin_puma do
    desc "Setup Puma initializer and app configuration"
    task :setup, :roles => :app do
      # Copy the scripts to services directory 
      template "puma-manager.erb", "/tmp/puma-manager.conf"
      run "#{sudo} mv /tmp/puma-manager.conf /etc/init/puma-manager.conf"
      # Create an empty configuration file
      template "puma.erb", "/tmp/puma.conf"
      run "#{sudo} mv /tmp/puma.conf /etc/init/puma.conf"
      # Create Puma application manifest
      run "#{sudo} touch /etc/puma.conf"
      run "echo ""#{deploy_to}/current"" > /tmp/puma.txt"
      run "#{sudo} cat /etc/puma.conf >> /tmp/puma.txt"
      run "#{sudo} mv /tmp/puma.txt /etc/puma.conf"
      # Create Puma Configuration File
      run "mkdir -p #{shared_path}/config/puma"
      template "puma-production.erb", "#{shared_path}/config/puma/production.rb"
    end
    after "deploy:setup", "rockin_puma:setup"

    desc "Symlink the production.rb file for puma into latest release"
    task :symlink, :roles => :app do
      run "ln -nfs #{shared_path}/config/puma/production.rb #{release_path}/config/puma/production.rb"
    end
    after "deploy:finalize_update", "rockin_puma:symlink" 
  end
end
