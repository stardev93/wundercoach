# set :rails_env, 'production'
# set :branch, 'master'
# set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }
# server 'liveapp.wundercoach.net', user: 'railsuser', roles: %w(web db app)
#
# set :deploy_to, '/var/www/go.wundercoach.net'


set :rails_env, 'production'

server 'live.wundercoach.net:2424', user: 'wundercoach', roles: %w(web db app)

set :deploy_to, '/var/www/go.wundercoach.net'

set :delayed_job_workers, 2
