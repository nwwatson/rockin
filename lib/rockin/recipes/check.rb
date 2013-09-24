Capistrano::Configuration.instance(:must_exist).load do
  set_default(:jruby, "")
  namespace :check do
    desc "Make sure local git is in sync with remote."
    task :revision, :roles => :web do
      unless jruby
        unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
          puts "WARNING: HEAD is not the same as origin/#{branch}"
          puts "Run `git push` to sync changes."
          exit
        end
      end
    end
    before "deploy", "check:revision"
    before "deploy:migrations", "check:revision"
    before "deploy:cold", "check:revision"
  end
end