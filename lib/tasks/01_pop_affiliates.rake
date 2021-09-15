namespace :wc do
  desc "Create 3 random affiliates"
  task pop_affiliates: :environment do
    require 'populator'
    require 'faker'
    Affiliate.destroy_all
    Affiliate.create({
      name: "Seminar 2 Go",
      name_addon: Faker::Company.bs,
      street: Faker::Address.street_name + ' ' + Faker::Address.building_number,
      zip: Faker::Address.zip,
      city: Faker::Address.city,
      country: 'DE',
      email: 'sascha.krone@seminar2go.com',
      firstname: 'Sascha',
      lastname: 'Krone'
    })
    2.times do |i|
      Affiliate.create({
        name: Faker::Company.name + ' ' + Faker::Company.suffix,
        name_addon: Faker::Company.bs,
        street: Faker::Address.street_name + ' ' + Faker::Address.building_number,
        zip: Faker::Address.zip,
        city: Faker::Address.city,
        country: %w(DE US GB CH AT).sample,
        email: Faker::Internet.email,
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name
      })
    end
    Affiliate.find_each do |affiliate|
      Affiliate::Tag.populate 5 do |tag|
        tag.name = Faker::Company.unique.profession
        tag.affiliate_id = affiliate.id
      end
      Affiliate::EventList.populate 5 do |list|
        list.name = Faker::Lorem.words(2).join(' ').capitalize
        list.description = Faker::Lorem.paragraph
        list.affiliate_id = affiliate.id
      end
      Adpartner.populate 3 do |adpartner|
        adpartner.affiliate_id = affiliate.id
        adpartner.firstname = Faker::Name.first_name
        adpartner.lastname = Faker::Name.last_name
        adpartner.name = Faker::Company.name + ' ' + Faker::Company.suffix
        adpartner.name_addon = Faker::Company.bs
        adpartner.street = Faker::Address.street_name + ' ' + Faker::Address.building_number
        adpartner.zip = Faker::Address.zip
        adpartner.city = Faker::Address.city
        adpartner.country = %w(DE US GB CH AT)
        adpartner.email = Faker::Internet.email
        adpartner.website = Faker::Internet.domain_name
        adpartner.commission_relative = Faker::Number.decimal(1, 2)
        adpartner.commission_absolute = Faker::Number.decimal(1, 2)
      end
    end

    relative_commissions = Adpartner.all.pluck(:commission_relative)
    absolute_commissions = Adpartner.all.pluck(:commission_absolute)
    Order.find_each do |order|
      adpartner = Adpartner.find([1, 2, 3].sample)
      order.adpartner = adpartner
      order.adpartner_commission_relative = adpartner.commission_relative
      order.adpartner_commission_absolute = adpartner.commission_absolute
      order.affiliate_commission_relative = order.account.affiliate_commission_relative
      order.affiliate_commission_absolute = order.account.affiliate_commission_absolute
      order.save!
    end
    account = Account.first
    user = User.create!({
      account: account,
      email: 'sascha.krone@seminar2go.com',
      password: 'df74s94ws',
      lastname: 'Krone',
      firstname: 'Sascha',
      gender: %w(male female).sample,
      activation_state: 'active',
      external: false
    })
    user.activate!
    user.roles << Role.where(name: %w(user affiliate))
    puts '3 Affiliates generated! Task done.'
  end
end
