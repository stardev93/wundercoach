workers Integer(ENV['WEB_CONCURRENCY'] || 5)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'production'
app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/tmp"
#pidfile ENV["PIDFILE"] || "#{shared_dir}/pids/puma.pid"
#bind "unix://#{shared_dir}/sockets/puma.sock"