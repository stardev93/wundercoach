namespace :wc do
  desc 'Create inital data required for system setup'
  task livedata: :environment do
    Rake::Task['db:reset'].invoke # drop,create,load schema and necessary data (no test data)
    Rake::Task['db:seed'].invoke
  end
end
