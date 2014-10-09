Capistrano::Configuration.instance(:must_exist).load do
  set :mongodb_data_path, "/data/db"
  set :mongodb_bin_path, "/opt/mongo"
  set :mongodb_log, "/var/log/mongodb.log"

  namespace :mongodb do    
    desc "Installs mongodb binaries and all dependencies"
    task :install, :role => :app do
      run "#{sudo} apt-get -y tcsh scons g++ libpcre++-dev"
      run "#{sudo} apt-get -y libboost1.37-dev libreadline-dev xulrunner-dev"
      mongodb.make_spidermonkey
      mongodb.make_mongodb
      mongodb.setup_db_path
    end

    task :make_spidermonkey, :role => :app do
      run "mkdir -p ~/tmp"
      run "cd ~/tmp; wget ftp://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz"
      run "cd ~/tmp; tar -zxvf js-1.7.0.tar.gz"
      run "cd ~/tmp/js/src; export CFLAGS=\"-DJS_C_STRINGS_ARE_UTF8\""
      run "cd ~/tmp/js/src; #{sudo} make -f Makefile.ref"
      run "cd ~/tmp/js/src; #{sudo} JS_DIST=/usr make -f Makefile.ref export"
    end

    task :make_mongodb, :role => :app do
      sudo "rm -rf ~/tmp/mongo"
      run "cd ~/tmp; git clone git://github.com/mongodb/mongo.git"
      run "cd ~/tmp/mongo; #{sudo} scons all"
      run "cd ~/tmp/mongo; #{sudo} scons --prefix=#{mongodb_bin_path} install"
    end

    task :setup_db_path, :role => :app do
      sudo "mkdir -p #{mongodb_data_path}"
      mongodb.start
    end
    
    desc "Starts the mongodb server"
    task :start, :role => :app do
      sudo "#{mongodb_bin_path}/bin/mongod --fork --logpath #{mongodb_log} --logappend --dbpath #{mongodb_data_path}"
    end

    desc "Stop the mongodb server"
    task :stop, :role => :app do
      pid = capture("ps -o pid,command ax | grep mongod | awk '!/awk/ && !/grep/ {print $1}'")
      sudo "kill -INT #{pid}" unless pid.strip.empty?
    end

    desc "Restart the mongodb server"
    task :restart, :role => :app do
      pid = capture("ps -o pid,command ax | grep mongod | awk '!/awk/ && !/grep/ {print $1}'")
      mongodb.stop unless pid.strip.empty?
      mongodb.start
    end
    
  end
end
