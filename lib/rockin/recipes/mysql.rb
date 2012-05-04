Capistrano::Configuration.instance(:must_exist).load do
  # TASKS:
  # mysql:install - downloads mysql packages
  # mysql:setup  - creates and copies database.yml file
  # mysql:create_database - creates DB in mysql console
  # mysql:symlink - on deploy creates symlink from #{current_path} to #{shared_path}

  set_default(:mysql_host, "localhost")
  set_default(:mysql_user) { application }
  set_default(:mysql_password) { Capistrano::CLI.password_prompt "! MySQL database password: " }
  set_default(:mysql_root_password) { Capistrano::CLI.password_prompt "! MySQL root password: " }
  set_default(:mysql_database) { "#{application}_production" }

  namespace :mysql do
  
    desc "Install the latest stable release of MySql."
    task :install, roles: :db, only: {primary: true} do
      #run "echo #{mysql_password}"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install mysql-server" do |channel, stream, data|
        # prompts for mysql root password (when blue screen appears)
        channel.send_data("#{mysql_root_password}\n\r") if data =~ /password/
      end
      run "#{sudo} apt-get -y install mysql-client libmysqlclient-dev"
    end
    after ("deploy:install", "mysql:install") if database.eql?("mysql")


    desc "Create a database and user for this application."
    task :create_database, roles: :db, only: {primary: true} do
      put "create database #{mysql_database};
      grant all on #{mysql_database}.* to '#{mysql_user}'@'#{mysql_host}' identified by '#{mysql_password}';", "/tmp/mysql_create"
      run "mysql -u root -p'#{mysql_root_password}' < /tmp/mysql_create"
      run "rm /tmp/mysql_create"
    end
    after ("deploy:setup", "mysql:create_database") if database.eql?("mysql")


    desc "Generate the database.yml configuration file."
    task :setup, roles: :app do
      run "mkdir -p #{shared_path}/config"
      put template("mysql.yml.erb"), "#{shared_path}/config/database.yml"
    end
    after ("deploy:setup", "mysql:setup") if database.eql?("mysql")


    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
    after ("deploy:finalize_update", "mysql:symlink") if database.eql?("mysql")
  end
end