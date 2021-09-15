namespace :wc do
  desc "Create events for each account"
  task :pop_eventsold => :environment do
    require 'populator'
    require 'faker'

    tag_names = Array.new(5) { Faker::Job.unique.key_skill }

    puts 'Populating events and eventtemplates for each account'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      Event.populate 20 do |event|
        event.account_id = i
        event.name = Faker::Company.catch_phrase
        event.shortdescription = Faker::Lorem.paragraph
        event.longdescription = Faker::Lorem.paragraph(10, sentence_count=3)
        event.bottom_text = Faker::Lorem.paragraph(4)
        event.allow_signup = [false, true]
        event.onlinestatus_id = [2, 2, 2, 2, 1, 3]
        event.planningstatus_id = [2]
        event.type = %w(StandardEvent StandardEvent StandardEvent IndividualEvent FreeEvent)

        unless i.even?
          event.external_signup_url = Faker::Internet.url('example.com')
          event.external_signup_text = "Die Anmeldung zu dieser Veranstaltung erfolgt über unseren Partner example.com. Klicken Sie hier, um sich dort anzumelden."
        end

        event.maxparticipants = [8, 15, 22]
        event.max_additional_participants = 0

        event.duration = [1, 2, 3]
        event.durationunit_id = 2
        #event.start_date = Faker::Date.between(Date.today + 30.days, Date.today + 120.days)
        event.start_date = Faker::Date.between(Date.today, Date.today + 60.days)
        event.start_date = event.start_date + 10.hours

        event.end_date = event.start_date + event.duration.days
        event.end_date = event.end_date + 8.hours

        event.latest_signup_date = event.start_date - 30.days

        event.full_price_cents = [990_000, 1200_000, 1250_000]
        event.price_early_signup_cents = event.full_price_cents - 15_000
        if event.type == 'FreeEvent'
          event.full_price_cents = 0
          event.price_early_signup_cents = 0
        end
        event.early_signup_pricing = [true, false]
        event.early_signup_deadline = Date.today
        event.eventtype_id = Eventtype.pluck(:id)
        event.currency = 'EUR'

        event.generate_invoice = [true, true, true, true, false]
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

      Product::Tag.create(tag_names.map { |tag_name| {name: tag_name} })

      tags = Product::Tag.all.to_a

      Event.find_each do |event|
        event.tags << tags.sample(2)
      end

      Eventtemplate.populate 5 do |eventtemplate|

        eventtemplate.account_id = account.id
        eventtemplate.name = Faker::Company.catch_phrase
        eventtemplate.shortdescription = Faker::Lorem.paragraph
        eventtemplate.longdescription = Faker::Lorem.paragraph(10, sentence_count=3)
        eventtemplate.bottom_text = Faker::Lorem.paragraph(4)
        eventtemplate.allow_signup = [false, true]
        eventtemplate.colorcode = %w(#db0d0d #2e16c9 #14c92c #b51bdb)
        eventtemplate.meta_title = eventtemplate.name
        eventtemplate.meta_description = eventtemplate.shortdescription
        eventtemplate.meta_keywords = eventtemplate.shortdescription
        eventtemplate.use_tracking = true

        if eventtemplate.allow_signup == true
          eventtemplate.external_signup_url = Faker::Internet.url('example.com')
          eventtemplate.external_signup_text = "signup here"
        end

        eventtemplate.maxparticipants = [10, 12, 20]
        eventtemplate.max_additional_participants = 0

        eventtemplate.duration = [1, 2, 3]
        eventtemplate.durationunit_id = 2

        eventtemplate.full_price_cents = [99_000, 120_000, 125_000]
        eventtemplate.price_early_signup_cents = eventtemplate.full_price_cents - 15_000
        eventtemplate.currency = 'EUR'
        eventtemplate.early_signup_pricing = [true, false]
        eventtemplate.eventtype_id = Eventtype.pluck(:id)

        eventtemplate.generate_invoice = [true, true, true, true, false]

        eventtemplate.eventorganizer = Faker::Company.name + ' ' + Faker::Company.suffix
        eventtemplate.location = Faker::Address.community
        eventtemplate.street = Faker::Address.street_name
        eventtemplate.streetno = Faker::Address.building_number
        eventtemplate.zip = Faker::Address.zip
        eventtemplate.city = Faker::Address.city
        eventtemplate.country = "DE"
        eventtemplate.latitude = Faker::Address.latitude
        eventtemplate.longitude = Faker::Address.longitude
        eventtemplate.enable_crm = false
        eventtemplate.show_remaining_seats_count = [true, false]
      end

      Eventtemplate.find_each do |eventtemplate|
        eventtemplate.tags << tags.sample(3)
      end
      puts "Populating events #{i*10}% done."

      puts "Generating Slugs for Events and Eventtemplates."
      paymentmethods = Paymentmethod.where(key: %w(banktransfer vorkasse)).to_a
      Event.find_each do |event|
        event.paymentmethods << paymentmethods.sample
        event.save!
      end
      Eventtemplate.find_each(&:save!)
      puts "Done."

      @events = Event.all
      puts "Assigning eventpaymentmethods."
      @events.each do |event|
        eventpaymentmethod = Eventpaymentmethod.create!({
          event: event,
          paymentmethod_id: [4,5].sample
        })
        eventpaymentmethod.save!
      end
      puts "Done."

      # Eventtemplate.find_each do |template|
      #   5.times do
      #     event = Event.create_from_template(template)
      #     event.update!({
      #       onlinestatus: Onlinestatus.find_by(key: 'online'),
      #       planningstatus: Planningstatus.find_by(key: 'planned'),
      #       start_date: (1..7).to_a.sample.days.from_now,
      #       allow_signup: true,
      #       early_signup_deadline: Date.today
      #     })
      #   end
      # end
    end
  end
end
