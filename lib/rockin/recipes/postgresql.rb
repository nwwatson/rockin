Capistrano::Configuration.instance(:must_exist).load do
  set_default(:postgres_install, false)
  set_default(:postgres_create_database, false)
  set_default(:postgresql_host) { Capistrano::CLI.password_prompt "PostgreSQL Host: " }
  set_default(:postgresql_user) { Capistrano::CLI.password_prompt "PostgreSQL User: " }
  set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
  set_default(:postgresql_database) { Capistrano::CLI.password_prompt "PostgreSQL Database: " }

  namespace :postgresql do
    desc "Install the latest stable release of PostgreSQL."
    task :install, :roles => :db, :only => { :primary => true } do
      if postgres_install.eql?(true)
        run "#{sudo} apt-get -y install postgresql libpq-dev"
        run "#{sudo} apt-get -y install postgresql-contrib"
      else 
        # File needed to connect to postgres and install pg client gem
        run "#{sudo} apt-get -y install postgresql-client libpq-dev"
      end
    end
    if database.eql?("postgresql")
      after "deploy:install", "postgresql:install" 
    end
    
    desc "Create a database for this application."
    task :create_database, :roles => :db, :only => { :primary => true } do
      run %Q{#{sudo} -u postgres psql -h #{postgresql_host} -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
      run %Q{#{sudo} -u postgres psql -h #{postgresql_host} -c "create database #{postgresql_database} owner #{postgresql_user};"}
      run %Q{#{sudo} -u postgres psql -h #{postgresql_host} -d #{postgresql_database} -c "CREATE EXTENSION hstore;"}
    end
    if database.eql?("postgresql") && postgres_create_database.eql?(true)
      after "deploy:setup", "postgresql:create_database" 
    end
    
    desc "Generate the database.yml configuration file."
    task :setup, :roles => :app do
      run "mkdir -p #{shared_path}/config"
      template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
    end
    if database.eql?("postgresql")
      after "deploy:setup", "postgresql:setup" 
    end

    desc "Symlink the database.yml file into latest release"
    task :symlink, :roles => :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
    if database.eql?("postgresql")
      after "deploy:finalize_update", "postgresql:symlink" 
    end
  end
end
