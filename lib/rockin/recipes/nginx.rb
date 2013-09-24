Capistrano::Configuration.instance(:must_exist).load do
  set_default(:nginx_multiple_sites, true)
  set_default(:nginx_app_server, "unicorn")
  set_default(:jruby, false)
  set_default(:trinidad_port) { 3000 }
  set_default :jruby_proxy_port, 3000
  
  namespace :nginx do
    desc "Install nginx"
    task :install, :roles => :web do
      run "#{sudo} apt-get -y install nginx"
    end
    after "deploy:install", "nginx:install"

    desc "Setup nginx configuration for this application"
    task :setup, :roles => :web do
      template "nginx_#{nginx_app_server}.erb", "/tmp/nginx_conf"
      run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
      run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
      restart
    end
    after "deploy:setup", "nginx:setup"
  
    %w[start stop restart].each do |command|
      desc "#{command} nginx"
      task command, :roles => :web do
        run "#{sudo} service nginx #{command}"
      end
    end
  end
end
