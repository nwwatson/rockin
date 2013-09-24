Capistrano::Configuration.instance(:must_exist).load do
  set_default(:puma_environment) { "production" }
  set_default(:puma_bind) { "unix://#{shared_path}/tmp/puma/puma.sock" }
  set_default(:puma_pid) { "#{shared_path}/tmp/pids/puma.pid" }
  set_default(:state_path) { "#{shared_path}/tmp/puma/state" }
  set_default(:puma_config) { "#{shared_path}/config/puma.rb" }
  set_default(:puma_log) { "#{shared_path}/log/puma.log" }

  namespace :puma do
    desc "Setup Puma initializer and app configuration"
    task :setup, :roles => :app do
      # Copy the scripts to services directory 
      template "puma-manager.conf", "/tmp/puma-manager.conf"
      run "#{sudo} mv /tmp/puma-manager.conf /etc/init"
      # Create an empty configuration file
      template "puma.conf", "/tmp/puma.conf"
      run "#{sudo} mv /tmp/puma.conf /etc/puma.conf"
    end
    after "deploy:setup", "puma:setup"
  end
end
