set :environment, (ENV['target'] || 'staging')

set :user, 'rtc'
set :application, user
set :deploy_to, "/projects/#{user}/"

set :sock, "#{user}.sock"

if environment == 'api' # production api box
  set :domain, 'ec2-50-17-0-114.compute-1.amazonaws.com' # unionstation
elsif environment == 'backend' # production scraper box
  set :domain, 'takoma.sunlightlabs.net' # takoma
else # environment == 'staging'
  set :domain, 'ec2-107-22-9-27.compute-1.amazonaws.com' # dupont
end


# RVM stuff - not sure how/why this works, awesome
set :rvm_ruby_string, '1.9.3-p194@rtc'
# rvm-capistrano gem must be installed outside of the bundle
require 'rvm/capistrano'


set :scm, :git
set :repository, "git@github.com:sunlightlabs/congress.git"
set :branch, 'rtc'

set :deploy_via, :remote_cache
set :runner, user
set :admin_runner, runner

role :app, domain
role :web, domain

set :use_sudo, false

# not sure why the issue
if environment != 'staging'
  after "deploy", "deploy:cleanup"
end

after "deploy:update_code", "deploy:shared_links"
after "deploy:update_code", "deploy:bundle_install"
after "deploy:update_code", "deploy:create_indexes"
after "deploy", "deploy:set_crontab"

namespace :deploy do
  task :start do
    if environment != 'backend'
      run "cd #{current_path} && unicorn -D -l #{shared_path}/#{sock} -c #{current_path}/unicorn.rb"
    end
  end
  
  task :stop do
    if environment != 'backend'
      run "kill `cat #{shared_path}/unicorn.pid`"
    end
  end
  
  task :migrate do; end
  
  desc "Restart the server"
  task :restart, :roles => :app, :except => {:no_release => true} do
    if environment != 'backend'
      run "kill -HUP `cat #{shared_path}/unicorn.pid`"
    end
  end
  
  desc "Create indexes"
  task :create_indexes, :roles => :app, :except => {:no_release => true} do
    run "cd #{release_path} && rake create_indexes"
  end
  
  desc "Install Ruby gems and Python eggs"
  task :bundle_install, :roles => :app, :except => {:no_release => true} do
    run "cd #{release_path} && bundle install --local"
    
    if environment != 'api'
      run "cd #{release_path} && pip install -r requirements.txt"
    end
  end
  
  # current_path is correct here because this happens after deploy, not after deploy:update_code
  desc "Load the crontasks"
  task :set_crontab, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && rake set_crontab environment=#{environment} current_path=#{current_path}"
  end

  desc "Stop the crontasks"
  task :disable_crontab, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && rake disable_crontab"
  end
  
  desc "Get shared files into position"
  task :shared_links, :roles => [:web, :app] do
    run "ln -nfs #{shared_path}/config.yml #{release_path}/config/config.yml"
    run "ln -nfs #{shared_path}/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/config.ru #{release_path}/config.ru"
    run "ln -nfs #{shared_path}/unicorn.rb #{release_path}/unicorn.rb"
    run "ln -nfs #{shared_path}/data #{release_path}/data"
    run "rm -rf #{File.join release_path, 'tmp'}"
    run "rm #{File.join release_path, 'public', 'system'}"
    run "rm #{File.join release_path, 'log'}"
    
    # elasticsearch files need to stay in a shared dir so that the symlink that points to them doesn't stay pointed
    # to stale, old releases
    if ['staging', 'elastic'].include?(environment)
      run "cp #{release_path}/config/elasticsearch/config/#{environment}/*.yml #{shared_path}/elasticsearch/"
      run "cp -r #{release_path}/config/elasticsearch/mappings/ #{shared_path}/elasticsearch/"
    end
  end
end