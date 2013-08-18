Capistrano::Configuration.instance(:must_exist).load do
  namespace :libreoffice do
    desc "Install libreoffice headless onto the server"
    task :install do
      run "#{sudo} apt-get -y install openjdk-7-jre libreoffice-common libreoffice-draw libreoffice-writer libreoffice-calc libreoffice-impress unoconv"
    end
    after "deploy:install", "libreoffice:install" 
  end
end
