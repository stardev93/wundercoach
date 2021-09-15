# can only be generated for an account
FactoryGirl.define do
  factory :standard_event do
    full_price 99.99
    maxparticipants 12
    max_additional_participants 0
    name "Test Event"
    eventtype
    onlinestatus Onlinestatus.find_by(key: "online")
    start_date Date.today + 5.days

    after(:build) do |event|
      event.paymentmethods << create(:paymentmethod)
    end

    factory :standard_event_with_confirmed_bookings do
      transient do
        bookings_count 5
      end

      after(:create) do |event, evaluator|
        create_list(:confirmed_eventbooking, evaluator.bookings_count, event: event, account: event.account)
      end
    end
  end
end
