namespace :deploy do
  desc 'Create users and helper table content'
  task :demo_data do
    on primary :db do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'wc:dd'
        end
      end
    end
  end
end
