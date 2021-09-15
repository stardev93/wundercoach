# can only be generated for an account
FactoryGirl.define do
  factory :event do
    name { Faker::Company.catch_phrase }
    shortdescription { Faker::Lorem.paragraph }
    longdescription { Faker::Lorem.paragraph(10, sentence_count=3) }
    bottom_text { Faker::Lorem.paragraph(4) }
    allow_signup { true }
    eventtype_id { 1 }
    maxparticipants { [8, 15, 22].sample }
    max_additional_participants { 0 }
    duration { 1 }
    durationunit_id { 2 }
    start_date Faker::Date.between(Date.today, Date.today + 60.days)
    eventorganizer { Faker::Company.name + ' ' + Faker::Company.suffix }
    location { Faker::Address.community }
    street { Faker::Address.street_name }
    streetno { Faker::Address.building_number }
    zip { Faker::Address.zip }
    city { Faker::Address.city }
    country { "DE" }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }

    after(:create) do |event|
      event.paymentmethods << create(:paymentmethod)
      event.vat = create(:vat)
    end

    trait :event_template do
      type "Eventtemplate"
    end

    trait :paid do
      full_price { Money.new(100, 'EUR') }
    end
  end

  factory :invalid_event, parent: :event do |f|
    f.name nil
  end
end
