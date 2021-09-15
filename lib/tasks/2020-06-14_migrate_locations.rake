namespace :wc do
  desc "Migrate locations for each event to product_locations"
  task :migrate_locations => :environment do
    require 'populator'
    require 'faker'

    Product::Location.destroy_all
    puts 'Populating locations for each account'
    puts '-------------------------------------'
    Account.all.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id
      puts "Acount: " + account.id.to_s + ' - ' + account.name.to_s
      puts '---------------------------'
      account.events.each do |event|
        puts "Event: " + event.id.to_s + ' - ' + event.to_s
        puts "max_additional_participants.nil?: " + event.max_additional_participants.nil?.to_s
        puts "max_additional_participants: " + event.max_additional_participants.to_s
        puts "maxparticipants.nil?: " + event.maxparticipants.nil?.to_s
        puts "maxparticipants: " + event.maxparticipants.to_s
        puts "full_price_cents: " + (event.full_price_cents > 0).to_s
        puts "price_early_signup_cents: " + (event.price_early_signup_cents > 0).to_s unless event.price_early_signup_cents.nil?

        location = Product::Location.new

        location.account_id = account.id

        location.eventorganizer_name = event.eventorganizer
        location.location_name = event.location.blank? ? event.name : event.location
        location.street = event.street
        location.streetno = event.streetno
        location.zip = event.zip
        location.city = event.city
        location.country = "DE"
        location.latitude = event.latitude
        location.longitude = event.longitude

        location.time_zone = event.account.get_time_zone
        location.show_time_zone_in_checkout = true

        location.displayed_address = ''

        location.cost_fixed_cents = 0
        location.cost_variable_cents = 0
        location.cost_variable_unit = 'd'

        location.directions = ''
        location.save!

        event.product_location = location
        if event.maxparticipants.nil?
          event.maxparticipants = 0
        end
        if ((event.max_additional_participants.nil?) || (event.max_additional_participants.to_i > 0)) && ((event.full_price_cents.to_i > 0) || (event.price_early_signup_cents.to_i > 0))
          event.max_additional_participants = 0
        end
        if event.max_additional_participants.nil?
          event.max_additional_participants = 0
        end

        if !event.slug.match(/\A[a-z0-9\d-]+\z/i) || (event.slug.include? "?")
          puts "I am here" + event.slug.to_s
          event.slug = ''
        end
        event.save!

        puts location.location_name + ' generated'

      end

    end
    puts 'Done migrating locations'
  end
end
