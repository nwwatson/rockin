Capistrano::Configuration.instance(:must_exist).load do
  set_default(:mongodb_host) { Capistrano::CLI.password_prompt "mongodb Host: " }
  set_default(:mongodb_database) { Capistrano::CLI.password_prompt "mongodb Database: " }

  namespace :mongodb do
    desc "Install the latest stable release of mongodb."
    task :install, :roles => :db, :only => { :primary => true } do
        # File needed to connect to postgres and install pg client gem
        run "#{sudo} apt-get -y install mongodb"
      end
    end
    if database.eql?("mongodb")
      after "deploy:install", "mongodb:install"
    end

    desc "Generate the database.yml configuration file."
    task :setup, :roles => :app do
      run "mkdir -p #{shared_path}/config"
      template "mongodb.yml.erb", "#{shared_path}/config/mongoid.yml"
    end
    if database.eql?("mongodb")
      after "deploy:setup", "mongodb:setup"
    end

    desc "Symlink the database.yml file into latest release"
    task :symlink, :roles => :app do
      run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    end
    if database.eql?("mongodb")
      after "deploy:finalize_update", "mongodb:symlink"
    end
  end
end
