require "rails_helper"

RSpec.describe FreeBooking, type: :model, skip: true do
  before(:each) do
    accounts = create_list(:account_with_events, 2)
    ActsAsTenant.current_tenant = accounts[0]
  end

  describe "#upgrade?" do
    before(:each) do
      @booking = create :free_booking, is_current: true
    end

    it "is true when booking pro" do
      successor = create(:invoice_booking, paymentplan: Paymentplan.pro)
      expect(successor.upgrade?(@booking)).to eq(true)
    end

    it "is true when booking premium" do
      successor = create(:invoice_booking, paymentplan: Paymentplan.premium)
      expect(successor.upgrade?(@booking)).to eq(true)
    end
  end
end
