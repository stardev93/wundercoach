namespace :wc do
  desc "Create locations for each account"
  task :pop_locations => :environment do
    require 'populator'
    require 'faker'

    Product::Location.destroy_all
    puts 'Populating locations for each account'
    puts '-------------------------------------'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id
      puts "Account " + account.to_s
      puts "============================"
      Product::Location.populate 5 do |location|

        # location.account_id = account.id
        # location.location_name = Faker::Company.name
        # location.eventorganizer_name = Faker::Company.name + ' ' + Faker::Company.suffix
        # location.street = Faker::Address.street_name
        # location.zip = Faker::Address.zip
        # location.city = Faker::Address.city
        # location.state = Faker::Address.state
        # location.country = ["DE","AT","CH"]
        # location.displayed_address = Faker::Company.name + ' ' + Faker::Company.suffix + "\r\n" + Faker::Address.street_name + "\r\n" + Faker::Address.zip + "\r\n" + Faker::Address.city + "\r\n" + Faker::Address.country

        location.account_id = account.id
        location.location_name = Faker::University.name
        location.eventorganizer_name =  Faker::Company.name + ' ' + Faker::Company.suffix
        location.street = Faker::Address.street_name
        location.streetno = Faker::Address.building_number
        location.zip = Faker::Address.zip_code
        location.city = Faker::Address.city
        location.state = Faker::Address.state
        #location.country = Faker::Address.country_code
        location.country = ["DE","AT","CH"]
        location.displayed_address = location.eventorganizer_name.to_s + "<br>" + "Henriettenweg 4<br>" + "20259 Hamburg<br>" + "Hamburg<br>" + ISO3166::Country["DE"].translations[I18n.locale.to_s]
        location.time_zone = ["Europe/Berlin"]
        location.latitude = Faker::Address.latitude
        location.longitude = Faker::Address.longitude
        location.show_time_zone_in_checkout = [true,true,false]

        location.displayed_address = location.location_name + "\r\n" + location.street + "\r\n" + location.zip + "\r\n" + location.city + "\r\n" + location.country

        location.cost_fixed_cents = 15000
        location.cost_variable_cents = 50000
        location.cost_variable_unit = 'd'

        location.directions = Faker::Lorem.paragraph(10, sentence_count=3)

        puts location.location_name + ' generated'
      end

    end
    puts 'Done populating locations'
  end
end
