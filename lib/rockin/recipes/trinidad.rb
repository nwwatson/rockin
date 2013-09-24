Capistrano::Configuration.instance(:must_exist).load do
  set_default(:trinidad_config_path) { "#{shared_path}/config/trinidad.yml" }
  set_default(:java_home){ "/usr/lib/jvm/java-1.7.0-openjdk-amd64/jre" }
  set_default(:trinidad_port) { 3000 }
  set_default :trinidad_config do
    {
      "port" => "#{trinidad_port}",
      "environment" => "production",
      "reload_strategy" => "rolling",
      "jruby_max_runtimes" => 1,
      "web_apps" => {
        "default" => {
          "root_dir" => "#{current_path}"
        }
      }
    }
  end
  
  set_default :trinidad_init_config do
    {
      "run_user" => user,
      "app_path" => "/home/#{user}/apps/",
      "trinidad_options" => "--config #{trinidad_config_path}",
      "ruby_compat_version" => "RUBY1_9",
      "jsvc_path" => "/usr/bin/jsvc",
      "java_home" =>"#{java_home}",
      "jruby_home" => "/home/#{user}/.rbenv/versions/#{ruby_version}",
      "pid_file" => "#{shared_path}/pids/trinidad.pid",
      "log_file" => "#{shared_path}/log/trinidad.log",
      "output_path" => "/tmp" # move later using sudo
    }
  end
  
  namespace :trinidad do
    desc "Setup Trinidad configuration for this application"
    task :setup, :roles => :app do
      put trinidad_config.to_yaml, trinidad_config_path
      put trinidad_init_config.to_yaml, "/tmp/trinidad_init.yml"
      run "gem install trinidad_init_services"
      run "trinidad_init_service /tmp/trinidad_init.yml"
      run "#{sudo} mv /tmp/trinidad /etc/init.d/trinidad"
      run "#{sudo} update-rc.d -f trinidad defaults"
      restart
    end
    after "deploy:setup", "trinidad:setup"
  
    desc "Reload application in Trinidad"
    task :reload, :roles => :app do
      run "touch #{current_release}/tmp/restart.txt"
    end
    after "deploy:restart", "trinidad:reload"
  
    %w[start stop restart].each do |command|
      desc "#{command} Trinidad"
      task command, :roles => :app do
        run "#{sudo} service trinidad_#{application} #{command}"
      end
    end
  end

end
