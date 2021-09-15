namespace :wc do
  desc "Create coaches for each account"
  task :pop_coaches => :environment do
    require 'populator'
    require 'faker'

    Coach.delete_all
    puts 'Populating coaches for each account'

    Faker::Config.locale = 'de'

    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      Coach.populate 3 do |coach|

        coach.account_id = account.id
        coach.lastname = Faker::Name.last_name
        coach.firstname = Faker::Name.male_first_name
        coach.gender = 'male'
        coach.email = Faker::Internet.email
        coach.price_cents = 8000.to_i
        coach.price_unit = 'h'
        coach.tel = Faker::PhoneNumber.phone_number
        coach.active = true
      end

      Coach.populate 3 do |coach|

        coach.account_id = account.id
        coach.lastname = Faker::Name.last_name
        coach.firstname = Faker::Name.female_first_name
        coach.gender = 'female'
        coach.email = Faker::Internet.email
        coach.price_cents = 12000.to_i
        coach.price_unit = 'h'
        coach.tel = Faker::PhoneNumber.phone_number
        coach.active = true
      end

    end
    puts 'Done populating coaches'
  end
end
