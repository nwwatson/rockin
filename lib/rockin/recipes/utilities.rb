Capistrano::Configuration.instance(:must_exist).load do
  
  desc "tail production log files" 
  task :tail_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}" 
      break if stream == :err    
    end
  end
  
  module Utilities
  
    def apt_install(packages)
      packages = packages.split(/\s+/) if packages.respond_to?(:split)
      packages = Array(packages)
      apt_get="DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get"
      sudo "#{apt_get} -qyu --force-yes install #{packages.join(" ")}"
    end

    def apt_upgrade
      apt_get="DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get"
      sudo "#{apt_get} -qy update"
      sudo "#{apt_get} -qyu --force-yes upgrade"
    end
  end
end