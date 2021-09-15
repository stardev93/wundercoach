require "rails_helper"

RSpec.describe Event, type: :model, skip: true do
  it "is available only to it's tenant" do
    accounts = create_list(:account_with_events, 2)
    ActsAsTenant.current_tenant = accounts[0]

    expect(accounts[0].events).to eq(Event.all)
  end

  context "with free seats" do
    it "is bookable!" do
      tenant = Account.create!(email: "account@test.com")
      ActsAsTenant.current_tenant = tenant
      event = create(:standard_event, account: tenant)

      expect { create(:eventbooking, event: event, account: tenant) }
        .to_not raise_error
    end
  end

  context "without free seats" do
    it "cannot be booked" do
      tenant = Account.create!(email: "account@test.com")
      ActsAsTenant.current_tenant = tenant
      event = create :standard_event_with_confirmed_bookings,
                                 account: tenant,
                                 bookings_count: 12,
                                 maxparticipants: 12

      expect { create(:eventbooking, event: event, account: tenant) }
        .to raise_error ActiveRecord::RecordInvalid
    end
  end
end
