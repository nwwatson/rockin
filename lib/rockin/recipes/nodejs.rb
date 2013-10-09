Capistrano::Configuration.instance(:must_exist).load do
  namespace :nodejs do
    desc "Install the latest relase of Node.js"
    task :install, :roles => :app do
      run "#{sudo} apt-get install software-properties-common"
      run "#{sudo} apt-add-repository ppa:chris-lea/node.js-legacy"
      run "#{sudo} apt-get update"
      run "#{sudo} apt-get install nodejs=0.6.12~dfsg1-1ubuntu1"
    end
    after "deploy:install", "nodejs:install"
  end
end
