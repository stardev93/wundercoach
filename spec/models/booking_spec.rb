require "rails_helper"

RSpec.describe Booking, type: :model, skip: true do
  before(:each) do
    accounts = create_list(:account_with_events, 2)
    ActsAsTenant.current_tenant = accounts[0]
  end

  describe "#expire!" do
    before(:each) do
      @booking = create :expiring_trial_booking
    end

    it "activates another booking" do
      expect(@booking).to eq(Booking.current)
      @booking.expire!
      expect(Booking.last).to eq(Booking.current)
    end

    it "deactivates itself" do
      expect(@booking).to eq(Booking.current)
      @booking.expire!
      expect(@booking).to_not eq(Booking.current)
    end
  end

  describe "#upgrade?" do
    context "from pro to premium" do
      it "returns true" do
        current_booking = build :booking,
                                is_current: true,
                                paymentplan: Paymentplan.pro
        new_booking = build :booking,
                            paymentplan: Paymentplan.premium
        expect(new_booking.upgrade?(current_booking)).to eq(true)
      end
    end
    context "from premium to pro" do
      it "returns false" do
        current_booking = build :booking,
                                is_current: true,
                                paymentplan: Paymentplan.premium
        new_booking = build :booking,
                            paymentplan: Paymentplan.pro
        expect(new_booking.upgrade?(current_booking)).to eq(false)
      end
    end
    context "from paid to free" do
      it "returns false" do
        pro_booking = build :booking,
                            is_current: true,
                            paymentplan: Paymentplan.pro
        premium_booking = build :booking,
                                is_current: true,
                                paymentplan: Paymentplan.premium
        new_booking = build :free_booking
        expect(new_booking.upgrade?(pro_booking)).to eq(false)
        expect(new_booking.upgrade?(premium_booking)).to eq(false)
      end
    end
  end

  describe "#succeed_booking!" do
    context "on upgrade" do
      before(:each) do
        @adapter = instance_spy("StripePaymentAdapter")
        allow(@adapter).to receive(:charge!).and_return({})
        allow(ActsAsTenant.current_tenant).to receive(:payment_adapter) { @adapter }
      end

      it "creates its own billing period" do
        predecessor = create(:invoice_booking, paymentplan: Paymentplan.pro)
        successor = create(:invoice_booking, paymentplan: Paymentplan.premium)
        expect { successor.succeed_booking!(predecessor) }.to change { successor.billing_periods.count }.by(1)
        expect(BillingPeriod.last.booking).to eq(successor)
      end

      pending "charges the customer" do
        predecessor = create(:invoice_booking, paymentplan: Paymentplan.pro)
        successor = create(:invoice_booking, paymentplan: Paymentplan.premium)
        successor.succeed_booking!(predecessor)
        expect(@adapter).to have_recieved(:charge!)
      end

      context "when switching between paid plans" do
        before(:each) do
          @predecessor = create(:invoice_booking, paymentplan: Paymentplan.pro)
          @successor = create(:invoice_booking, paymentplan: Paymentplan.premium)
        end

        it "cancels the current BillingPeriod" do
          period = BillingPeriod.create! booking: @predecessor,
                                         start_date: Date.today - 5.days
          @successor.succeed_booking!(@predecessor)
          expect(period.reload.cancel_date).to eq(Date.today)
        end

        it "prorates the amount that is charged" do
          period = BillingPeriod.create! booking: @predecessor,
                                         start_date: Date.today - 5.days
          @successor.succeed_booking!(@predecessor)
          expect(BillingPeriod.first.price).to_not eq(@successor.paymentplan.price)
          expect(BillingPeriod.first.price).to eq((@successor.paymentplan.price - period.reload.cancel_refund).round)
        end
      end
    end
    context "on downgrade" do
      before(:each) do
        @predecessor = create(:booking, paymentplan: Paymentplan.premium, is_current: true)
        @successor = create(:booking, paymentplan: Paymentplan.pro)
        BillingPeriod.create! booking: @predecessor,
                              start_date: Date.today - 5.days
      end

      it "does not become the current booking" do
        @successor.succeed_booking!(@predecessor)
        expect(@predecessor.id).to eq(Booking.current.id)
      end

      it "cancels the current booking" do
        @successor.succeed_booking!(@predecessor)
        expect(@predecessor.valid_until).to eq(@predecessor.billing_periods.last.end_date)
      end
    end
  end
end
