require "rails_helper"

RSpec.describe TrialBooking, type: :model, skip: true do
  before(:each) do
    accounts = create_list(:account_with_events, 2)
    ActsAsTenant.current_tenant = accounts[0]
  end

  describe "#expire!" do
    before(:each) do
      @booking = create :expiring_trial_booking
    end

    context "without a successor" do
      it "creates a succeeding FreeBooking" do
        @booking.expire!
        expect(Booking.current).to be_a FreeBooking
        expect(ActsAsTenant.current_tenant.paymentplan).to be_free
      end
    end

    context "with an existing successor" do
      it "activates the successor" do
        successor = FreeBooking.create! valid_until: nil,
                                        paymentplan: Paymentplan.free,
                                        is_current: false
        @booking.expire!
        expect(Booking.current).to eq(successor)
        expect(ActsAsTenant.current_tenant.paymentplan).to eq(successor.paymentplan)
      end
    end
  end
end
