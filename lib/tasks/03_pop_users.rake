namespace :wc do
  desc "Create users for all events with random names and descriptions"
  task :pop_users => :environment do
    require 'populator'
    require 'faker'

    puts 'Creating Fake users for all accounts...'
    Account.find_each do |account|
      User.create!({
        account: account,
        email: Faker::Internet.email,
        password: "test01",
        lastname: Faker::Name.last_name,
        firstname: Faker::Name.first_name,
        gender: %w(male female).sample,
        activation_state: "active",
        external: false,
        has_message: true
      })
    end
    User.find_each do |user|
      user.activate!
      role = Role.find_by(name: 'user')
      Userrole.populate(1) do |userrole|
        userrole.user_id = user.id
        userrole.role_id = role.id
      end
    end
    puts 'Done.'
    puts 'Creating an Eventbooking for every event...'
    Event.where.not(type: 'IndividualEvent').each do |event|
      order = Order.create!({
        account_id: event.account_id,
        paymentmethod_id: (1..6).to_a.sample,
        product_id: event.id,
        product_type: "Event",
        order_date: Faker::Date.between(Date.today - 29.days, Date.today - 1.days),
        status: (0..5).to_a.sample,
        idempotency_key: SecureRandom.uuid,
        address_attributes: {
          account_id: event.account_id,
          lastname: Faker::Name.last_name,
          firstname: Faker::Name.first_name,
          gender: %w(male female).sample,
          email: Faker::Internet.email,
          company: ['', '', Faker::Company.name].sample,
          zip: Faker::Address.zip_code,
          city: Faker::Address.city,
          street: "#{Faker::Address.street_name} #{Faker::Address.building_number}",
          country: %w(DE GB US).sample
        }
      })
      Eventbooking.populate(3) do |eventbooking|
        eventbooking.order_id = order.id
        eventbooking.address_id = order.address.id
        eventbooking.eventbookingstatus_id = [2,3]
        eventbooking.account_id = event.account_id
        eventbooking.event_id = event.id
        eventbooking.booking_date = Faker::Date.between(Date.today + 11.days, Date.today + 29.days)
        eventbooking.created_at = Faker::Date.between(Date.today + 11.days, Date.today + 29.days)
        eventbooking.early_booking_applies = [true, false]
      end
    end
    puts 'Done.'
  end
end
