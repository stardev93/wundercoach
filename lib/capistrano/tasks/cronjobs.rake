namespace :deploy do
  desc 'Runs recurring tasks'
  task :run_cronjobs do
    on primary :db do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'cronjob:run_all'
        end
      end
    end
  end
end
