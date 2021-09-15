namespace :wc do
  desc "Create events for each account"
  task :pop_timezones => :environment do

    puts 'Populating accounts with Europe/Berlin timezone'
    Account.find_each do |account|
      puts account.name
      account.time_zone = "Europe/Berlin"
      account.save
    end
  end
end
