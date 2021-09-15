FactoryGirl.define do
  factory :eventbooking do
    address
    eventbookingstatus { create(:eventbookingstatus, :new) }
    booking_date Time.now
    factory :confirmed_eventbooking do
      eventbookingstatus { create(:eventbookingstatus, :confirmed) }
    end
  end
end
