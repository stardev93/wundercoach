namespace :wc do
  desc "Create 10 accounts with random names and descriptions"
  task pop_accounts: :environment do
    require 'populator'
    require 'faker'

    9.times do |i|
      Account::Register.call({
        name: Faker::Company.name,
        homepage: Faker::Internet.domain_name,
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name,
        creator: {
          email: Faker::Internet.email,
          password: "test01"
        }
      }, 'user.use_activation' => false)
    end
    Account.where("id > 1").each do |a|
      a.assign_attributes({
        name_addon: Faker::Company.catch_phrase,
        street: Faker::Address.street_name,
        streetno: Faker::Address.building_number,
        zip: Faker::Address.zip,
        city: Faker::Address.city,
        country: %w(DE US GB CH AT).sample,
        comments: Faker::Lorem.sentence(word_count = 20, supplemental = false, random_words_to_add = 10),
        email_billing_address: Faker::Internet.email,
        vat_included: [true, false].sample,
        gender: %w(male female).sample,
        tel1: Faker::PhoneNumber.phone_number,
        tel2: Faker::PhoneNumber.phone_number,
        fax: Faker::PhoneNumber.phone_number,
        subdomain: Faker::Internet.unique.domain_word,
        affiliate_commission_relative: Faker::Number.decimal(1, 2),
        affiliate_commission_absolute: Faker::Number.decimal(1, 2)
      })
      a.save!
    end
    Faker::Internet.unique.domain_word.clear
    puts '9 additional Accounts generated! Task done.'
  end
end
