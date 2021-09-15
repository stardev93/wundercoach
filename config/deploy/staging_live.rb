set :rails_env, 'staging'
set :branch, 'staging'
set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }
server 'liveapp.wundercoach.net', user: 'railsuser', roles: %w(web db app)

set :deploy_to, '/var/www/staging.wundercoach.net'
