require "rails_helper"

RSpec.describe Order, type: :model do
  include ActiveJob::TestHelper

  describe "#confirm" do
    let!(:user) { create(:user) }
    let(:address) { create(:address, account_id: user.account_id) }
    let!(:event_booking_status) { create(:eventbookingstatus, :confirmed) }

    before {
      ActsAsTenant.current_tenant = Account.first
    }

    context "advanced payment" do
      let!(:order) {
        create(:order,
          :vorkasse_payment_method,
          account_id: user.account_id,
          address: address,
          user: user)
      }

      it "assigns order date" do
        order.confirm
        expect(order.order_date).not_to be_nil
      end

      it "saves object to check validation" do
        order.save!
        expect(order.errors).to be_empty
      end

      it "sets status to 'waiting_for_payment'" do
        order.confirm
        expect(order.status).to eq('waiting_for_payment')
      end
    
      it "sends confirmation email" do
        expect {
          order.confirm
        }.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
    end

    context "other payment methods except advanced payment" do
      let!(:order) {
        create(:order,
          :bank_transfer_payment_method,
          account_id: user.account_id,
          address: address,
          user: user)
      }

      it "assigns order date" do
        order.confirm
        expect(order.order_date).not_to be_nil
      end

      it "saves object to check validation" do
        order.save!
        expect(order.errors).to be_empty
      end

      it "sets status to 'confirmed'" do
        order.confirm
        expect(order.status).to eq('confirmed')
      end

      it "sends confirmation email" do
        expect {
          order.confirm
        }.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
    end

    context "event booking" do
      let!(:order) {
        create(:order,
          :bank_transfer_payment_method,
          account_id: user.account_id,
          address: address,
          user: user)
      }

      it "creates an Eventbooking" do
        expect {
          order.confirm
        }.to change {
          Eventbooking.count
        }.by(1)
      end
    end

    context "invoice generation" do
      context "when the invoice must be generated" do
        let!(:invoice_status) { create(:invoice_status, :new) }
        let!(:invoice_type) { create(:invoice_type, :invoice) }
        let!(:payment_status_paid) { create(:payment_status, :paid) }
        let!(:payment_status_open) { create(:payment_status, :open) }

        let(:order) {
          create(:order,
            :vorkasse_payment_method,
            account_id: user.account_id,
            address: address,
            user: user,
            generate_invoice: true)
        }

        before {
          allow_any_instance_of(Billing::Invoice).to receive(:create_pdf).and_return({})
        }

        it "creates a Billing::Invoice" do
          expect {
            order.confirm
          }.to change {
            Billing::Invoice.count
          }.by(1)
        end

        it "sends the invoice by email" do
          expect {
            order.confirm
          }.to change {
            ActiveJob::Base.queue_adapter.enqueued_jobs.size
          }.by(2)
        end
      end
    end
  end
end