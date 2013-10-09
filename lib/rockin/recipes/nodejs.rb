Capistrano::Configuration.instance(:must_exist).load do
  namespace :nodejs do
    desc "Install the latest relase of Node.js"
    task :install, :roles => :app do
      # Installing Old Release of Node
      run "#{sudo} apt-get install software-properties-common"
      run "#{sudo} apt-add-repository -y ppa:chris-lea/node.js-legacy"
      run "#{sudo} apt-get update -y"
      run "#{sudo} apt-get install -y nodejs=0.6.12~dfsg1-1ubuntu1"
    end
    after "deploy:install", "nodejs:install"
  end
end
