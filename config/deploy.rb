# Please install the Engine Yard Capistrano gem
# gem install eycap --source http://gems.engineyard.com

require 'eycap/recipes'

# =============================================================================
# ENGINE YARD REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The :deploy_to variable must be the root of the application.

set :keep_releases, 5
set :application,   'myousica'
set :scm,           :git

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, 			lambda { source.query_revision(revision) { |cmd| capture(cmd) } }
#

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

task :production do
  set :user,          'adelaosrl'
  set :password,      'dshUak8s'

  set :dbuser, 'adelaosrl_db'
  set :dbpass, '4asrsWrh'
  set :dbhost, 'mysql50-3-master'
  set :dbname, 'myousica_production'

  set :deploy_to,     "/data/#{application}"
  set :deploy_via,    :filtered_remote_cache
  set :repository,    'git@myousica_github.com:vjt/myousica.git'
  set :repository_cache,    "/var/cache/engineyard/#{application}"
  set :monit_group,   'myousica'
  
  role :web, '65.74.174.196:8221' # mongrel, mongrel
  role :app, '65.74.174.196:8221', :mongrel => true, :sphinx => true
  role :db, '65.74.174.196:8221', :primary => true
  
  role :app, '65.74.174.196:8222', :no_release => true, :mongrel => true, :sphinx => true
  
  set :rails_env, 'production'

  set :environment_database, defer { dbname }
  set :environment_dbhost, defer { dbhost }
end

task :staging do
  set :user, 'myousica'
  set :password, 'plies25}chis'
  set :use_sudo, false

  set :dbuser, 'myousica'
  set :dbpass, 'Leann82-full'
  set :dbname, 'myousica'
  set :dbhost, 'localhost'

  set :deploy_to, "/srv/rails/#{application}"
  set :deploy_via,    :filtered_remote_cache
  set :repository,    'git@github.com:vjt/myousica.git'
  set :repository_cache,    "/var/cache/rails/#{application}"

  role :web, '89.97.211.110'
  role :app, '89.97.211.110'
  role :db, '89.97.211.110', :primary => :true

  set :rails_env, 'staging'
  set :environment_database, defer { dbname }
  set :environment_dbhost, defer { dbhost }

  namespace :deploy do
    task :restart do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end
end

# =============================================================================
# Any custom after tasks can go here.
after "deploy:setup", "setup_myousica_folders"
task :setup_myousica_folders, :roles => [:app, :web], :except  => {:no_release => true, :no_symlink => true} do
  setup_photos
  setup_avatars
end

task :setup_avatars, :roles => [:app, :web], :except  => {:no_release => true, :no_symlink => true} do
  run "cd #{shared_path}; mkdir avatars"
end

task :setup_photos, :roles => [:app, :web], :except  => {:no_release => true, :no_symlink => true} do
  run "cd #{shared_path}; mkdir photos"
end

after "deploy:symlink_configs", "myousica_symlinks"
task :myousica_symlinks, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  symlink_photos
  symlink_avatars
  symlink_audio
  symlink_videos
  symlink_multitrack
  symlink_splash
  symlink_players
end

task :symlink_photos, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  run "cd #{current_release}/public; rm -rf photos; ln -s #{shared_path}/photos ."
end

task :symlink_avatars, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  run "cd #{current_release}/public; rm -rf avatars; ln -s #{shared_path}/avatars ."
end

task :symlink_audio, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  run "cd #{current_release}/public; rm -rf audio; ln -s #{shared_path}/audio ."
end

task :symlink_videos, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  run "cd #{current_release}/public; rm -rf videos; ln -s #{shared_path}/videos ."
end

task :symlink_multitrack, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  run "cd #{current_release}/public rm -rf multitrack; ln -s #{shared_path}/multitrack ."
end

task :symlink_splash, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  run "cd #{current_release}/public rm -rf splash; ln -s #{shared_path}/splash ."
end

task :symlink_players, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  run "cd #{current_release}/public rm -rf players; ln -s #{shared_path}/players ."
end

# =============================================================================

# Don't change unless you know what you are doing!

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"
