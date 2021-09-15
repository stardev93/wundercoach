namespace :wc do
  desc "Create events for each account"
  task :pop_products => :environment do
    require 'populator'
    require 'faker'

    Product::Location.delete_all

    puts 'Populating products and alikes for each account'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      Product::Location.populate 10 do |l|
        l.account_id = i
        l.eventorganizer_name =  Faker::Company.name + ' ' + Faker::Company.suffix
        l.location_name = Faker::Educator.university
        l.street = Faker::Address.street_address
        l.zip = Faker::Address.zip
        l.city = Faker::Address.city
        l.country = Faker::Address.country_code
        l.googlemapslocation = ''
        l.latitude = Faker::Address.latitude
        l.longitude = Faker::Address.longitude
      end
    end
  end
end
