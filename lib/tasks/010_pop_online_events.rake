namespace :wc do
  desc "Create standard events"
  task :pop_online_events => :environment do
    require 'populator'
    require 'faker'

    puts 'Populating events and eventtemplates for each account'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      puts ' '
      puts 'Generating OnlineEvents for: ' + account.name.to_s
      puts '---------------------------------------------------'
      OnlineEvent.populate 20 do |event|
        event.account_id = i
        event.name = Faker::Company.catch_phrase
        puts event.name

        event.shortdescription = Faker::Lorem.paragraph
        event.longdescription = Faker::Lorem.paragraph(10, sentence_count=3)
        event.bottom_text = Faker::Lorem.paragraph(4)
        event.allow_signup = [true, true, true, true, false]
        event.onlinestatus_id = Onlinestatus.find_by(key: 'online')
        event.planningstatus_id = Planningstatus.find_by(key: 'planned')
        #event.type = %w(OnlineEvent)


        event.webinar_url = Faker::Internet.url('signup.example.com?userid=84737453489&pw=786437856834')
        event.webinar_provider = %w(Zoom WebEx TeamViewer 'Microsoft Teams')

        event.maxparticipants = [120, 200, 850]
        event.max_additional_participants = 0

        event.duration = [1, 2, 3]
        event.durationunit_id = 2

        event.start_date = Faker::Date.between(Date.today + 10.days, Date.today + 60.days)
        event.start_date = event.start_date + 10.hours

        event.end_date = event.start_date + event.duration.days
        event.end_date = event.end_date + 8.hours

        event.latest_signup_date = event.start_date - 10.days

        event.full_price_cents = [990_000, 1200_000, 1250_000]
        event.price_early_signup_cents = event.full_price_cents - 15_000

        event.early_signup_pricing = [true]
        event.early_signup_deadline = event.start_date - 10.days

        event.eventtype_id = Eventtype.pluck(:id)
        event.currency = 'EUR'

        event.generate_invoice = [true]
        event.vat_id = Vat.find_by key: "regular_vat"

        event.enable_crm = false
        event.show_remaining_seats_count = [false, true, true]
        event.webinar_url = "https://zoom.us/event=urh4r7r4u4z4ri&userid=948493943&pw=983736264jeg46u"
        event.webinar_url_valid_from = Faker::Date.between(Date.today, Date.today + 20.days)
        event.webinar_provider = "Zoom"
        event.webinar_help_url = "https://zoom.us/help"
        event.webinar_username = "mustermann"
        event.webinar_pw = "ieu37w3ee32"
        event.webinar_additional_information = "Dies ist ein Online - Seminar. Sie erhalten die Zugangsdaten rechtzeitig per E-Mail."
        event.webinar_additional_information_short = "Dies ist ein Online - Seminar."

      end

    end
  end
end
