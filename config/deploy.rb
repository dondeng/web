# config valid only for current version of Capistrano
lock '3.3.5'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5


set :application, 'squash'
set :repo_url, 'https://github.com/dondeng/web.git'
set :deploy_to, '/home/ubuntu/www/squash'

set :log_level, :debug
set :ssh_options, {forward_agent: true}
set :use_sudo, false
set :default_stage, 'sandbox'


# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/sidekiq.yml
                      config/environments/common/authentication.yml
                      config/environments/common/concurrency.yml
                      config/environments/common/dogfood.yml
                      config/environments/common/javascript_dogfood.yml
                      config/environments/common/jira.yml
                      config/environments/common/mailer.yml
                      config/environments/common/pagerduty.yml
                      config/environments/common/repositories.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system assets config/environments/common
                     config/environments/production}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc "Restart Application"
  task :reload do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "service apache2 reload"
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "service apache2 stop"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
