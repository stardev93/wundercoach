namespace :wc do
  desc 'Create users and helper table content'
  task dd: :environment do
    Rake::Task['db:reset'].invoke # drop,create,load schema and seed
    #Rake::Task['wc:pop_helper'].invoke
    Rake::Task['wc:pop_accounts'].invoke
    Rake::Task['wc:pop_users'].invoke
    Rake::Task['wc:pop_smtpservers'].invoke

    Rake::Task['wc:pop_eventtypes'].invoke
    Rake::Task['wc:pop_standard_events'].invoke
    Rake::Task['wc:pop_free_events'].invoke
    Rake::Task['wc:pop_individual_events'].invoke
    Rake::Task['wc:pop_bundle_events'].invoke
    Rake::Task['wc:pop_online_events'].invoke

    Rake::Task['wc:configure_events'].invoke
    Rake::Task['wc:pop_eventtags'].invoke

    Rake::Task['wc:pop_eventbookings'].invoke

    #Rake::Task['wc:pop_affiliates'].invoke

    Rake::Task['wc:pop_products'].invoke
    Rake::Task['wc:pop_contacts'].invoke
    Rake::Task['wc:pop_locations'].invoke
    Rake::Task['wc:pop_coaches'].invoke
    Rake::Task['wc:pop_messages'].invoke
    Rake::Task['wc:pop_pricingoptions'].invoke
  end
  desc 'Create a lot of non sense data for statistics'
  task statistics: :environment do
    require 'populator'
    require 'faker'

    99.times do
      a = Account.new({
        name: Faker::Company.name,
        name_addon: Faker::Company.catch_phrase,
        street: Faker::Address.street_name,
        streetno: Faker::Address.building_number,
        zip: Faker::Address.zip,
        city: Faker::Address.city,
        country: %w(DE US GB CH AT).sample,
        homepage: Faker::Internet.domain_name,
        comments: Faker::Lorem.sentence(20, false, 10),
        email_billing_address: Faker::Internet.email,
        vat_included: [true, false].sample,
        gender: %w(male female).sample,
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name,
        tel1: Faker::PhoneNumber.phone_number,
        tel2: Faker::PhoneNumber.phone_number,
        fax: Faker::PhoneNumber.phone_number,
        email: Faker::Internet.email,
        subdomain: Faker::Internet.domain_word
      })
      a.save!
      a.setup!
    end

    puts '99 additional Accounts generated!'

    # Create random Bookings
    plans = Paymentplan.all.to_a
    Booking.update_all(valid_until: 2.months.ago)
    Account.find_each do |account|
      ActsAsTenant.with_tenant(account) do
        plan = plans.sample
        booking =
          if plan.free?
            FreeBooking.new(paymentplan: plan)
          else
            InvoiceBooking.new(paymentplan: plan)
          end
        booking.succeed_booking!(Booking.current)
      end
      account.update_column(:created_at, Faker::Date.between(6.months.ago, Date.today))
    end
    InvoiceBooking.find_each do |booking|
      periods = [Date.today, 1.month.ago, 2.months.ago, 3.months.ago].map do |date|
        {
          start_date: date,
          account: booking.account,
          booking: booking
        }
      end
      BillingPeriod.create!(periods)
    end
    BillingPeriod.find_each do |period|
      start_date = Faker::Date.between(6.months.ago, Date.today)
      period.update!(start_date: start_date, end_date: start_date + 1.months)
    end
    puts 'Done.'
  end
end
