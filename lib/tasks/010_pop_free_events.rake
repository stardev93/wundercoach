namespace :wc do
  desc "Create free events"
  task :pop_free_events => :environment do
    require 'populator'
    require 'faker'

    puts 'Populating free events for each account'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      puts ' '
      puts 'Generating FreeEvents for: ' + account.name.to_s
      puts '---------------------------------------------------'
      Event.populate 20 do |event|
        event.account_id = i
        event.name = Faker::Company.catch_phrase
        puts event.name

        event.shortdescription = Faker::Lorem.paragraph
        event.longdescription = Faker::Lorem.paragraph(10, sentence_count=3)
        event.bottom_text = Faker::Lorem.paragraph(4)
        event.allow_signup = [true, true, true, true, false]
        event.onlinestatus_id = Onlinestatus.find_by(key: 'online')
        event.planningstatus_id = Planningstatus.find_by(key: 'planned')
        event.type = %w(FreeEvent)

        event.maxparticipants = [8, 15, 22]
        event.max_additional_participants = 0

        event.duration = [1, 2, 3]
        event.durationunit_id = 2

        event.start_date = Faker::Date.between(Date.today + 10.days, Date.today + 120.days)
        event.start_date = event.start_date + 10.hours

        event.end_date = event.start_date + event.duration.days
        event.end_date = event.end_date + 8.hours

        event.latest_signup_date = event.start_date - 10.days

        event.full_price_cents = 0
        event.price_early_signup_cents = 0

        event.early_signup_pricing = [false]
        #event.early_signup_deadline = Date.today + 10.days

        event.eventtype_id = Eventtype.pluck(:id)
        event.currency = 'EUR'

        event.generate_invoice = [true]
        event.vat_id = Vat.find_by key: "regular_vat"

        event.eventorganizer = Faker::Company.name + ' ' + Faker::Company.suffix
        event.location = Faker::Address.community
        event.street = Faker::Address.street_name
        event.streetno = Faker::Address.building_number
        event.zip = Faker::Address.zip
        event.city = Faker::Address.city
        event.country = "DE"
        event.latitude = Faker::Address.latitude
        event.longitude = Faker::Address.longitude
        event.enable_crm = false
        event.show_remaining_seats_count = [false, true, true]
      end

    end
  end
end
