load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :application, 'cafe'
set :deploy_to, "/www/webop/apps/#{application}"
set :use_sudo, false

set :user, 'hurrinre'
set :domain, 'renpppcmhdev01.reedref.com'

role :app, domain
role :web, domain
role :db, domain

set :scm, :git
set :repository, "file:///var/git/#{application}.git"
set :local_repository, "#{user}@#{domain}:/var/git/#{application}.git"
set :branch, 'master'

namespace :deploy do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

desc 'Symlink the data folder'
task :symlink_data do
  run "rm -rf #{current_path}/data"
  run "ln -sf #{shared_path}/data #{current_path}/data"
end

after :deploy, :symlink_data, 'deploy:cleanup'