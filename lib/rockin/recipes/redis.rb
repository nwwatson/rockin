Capistrano::Configuration.instance(:must_exist).load do
  namespace :postgresql do
    desc "Install the latest stable release of Redis available in Ubuntu repositories."
    task :install, roles: :db, only: {primary: true} do
      run "#{sudo} apt-get -y install redis-server"
    end
  end
end
