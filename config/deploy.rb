# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'Wundercoach'
set :repo_url, 'git@bitbucket.org:wundercoach/wundercoach.git'

set :user,  'wundercoach'
set :group, 'deployers'

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/application.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/invoices', 'tmp/accountinvoices', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'private/system', 'public/system')

set :passenger_restart_with_touch, true

# -----------------------------------------------------------------
# Config for Capistrano DB Tasks (pushing and pulling db and assets)
# -----------------------------------------------------------------

# if you want to remove the local dump file after loading
set :db_local_clean, true

# if you want to remove the dump file from the server after downloading
set :db_remote_clean, true

# if you want to exclude table from dump
# set :db_ignore_tables, []

# if you want to exclude table data (but not table schema) from dump
# set :db_ignore_data_tables, []

# configure location where the dump file should be created
set :db_dump_dir, '/tmp'

# If you want to import assets, you can change default asset dir (default = system)
# This directory must be in your shared directory on the server
set :assets_dir, %w(public/system private/system)
set :local_assets_dir, %w(public private)

# if you are highly paranoid and want to prevent any push operation to the server
set :disallow_pushing, true
