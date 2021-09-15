namespace :wc do
  desc "Create bundle events"
  task :pop_bundle_events => :environment do
    require 'populator'
    require 'faker'

    puts 'Populating bundle events for each account'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      puts ' '
      puts 'Generating BundleEvents for: ' + account.name.to_s
      puts '---------------------------------------------------'
      BundleEvent.populate 20 do |event|
        event.account_id = i
        event.name = Faker::Company.catch_phrase
        puts event.name

        event.shortdescription = Faker::Lorem.paragraph
        event.longdescription = Faker::Lorem.paragraph(10, sentence_count=3)
        event.bottom_text = Faker::Lorem.paragraph(4)
        event.allow_signup = [true, true, true, true, false]
        event.onlinestatus_id = Onlinestatus.find_by(key: 'online')
        event.planningstatus_id = Planningstatus.find_by(key: 'planned')
        event.type = %w(BundleEvent)

        event.maxparticipants = [8, 15, 22]
        event.max_additional_participants = 0

        event.duration = [1, 2, 3]
        event.durationunit_id = 2

        event.full_price_cents = [11500_000, 4450_000, 1850_000]
        event.price_early_signup_cents = event.full_price_cents - 15_000

        event.early_signup_pricing = [true]
        event.early_signup_deadline = Date.today + 10.days

        event.eventtype_id = Eventtype.pluck(:id)
        event.currency = 'EUR'

        event.generate_invoice = [true]
        event.vat_id = Vat.find_by key: "regular_vat"

        # event.eventorganizer = Faker::Company.name + ' ' + Faker::Company.suffix
        # event.location = Faker::Address.community
        # event.street = Faker::Address.street_name
        # event.streetno = Faker::Address.building_number
        # event.zip = Faker::Address.zip
        # event.city = Faker::Address.city
        # event.country = "DE"
        # event.latitude = Faker::Address.latitude
        # event.longitude = Faker::Address.longitude
        event.enable_crm = false
        event.show_remaining_seats_count = [false, true, true]
      end

      BundleEvent.find_each do |bundle_event|
        standard_events = StandardEvent.pluck(:id).sample(5)
        EventSubevent.create(
          standard_events.map {|standard_event| {subevent_id: standard_event, event_id: bundle_event.id}}
        )
      end
    end
  end
end
