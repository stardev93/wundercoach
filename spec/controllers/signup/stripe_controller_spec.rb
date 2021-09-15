require "rails_helper"

RSpec.describe Signup::StripeController, type: :controller do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#create' do
    let(:locale) { 'de' }
    let(:user) { create(:user) }

    before {
      request.env['HTTP_REFERER'] = "http://#{user.account.subdomain}.lvh.me/signup/orders/#{order.id}/confirm"
      request.host = "#{user.account.subdomain}.lvh.me"
	    login_user(user)
    }

    context "with access denied" do
      context "when doesn't have 'payment_chosen' status" do
        let!(:order) {
          create(:order, account_id: user.account_id, user: user)
        }

        before {
			  	get :create, locale: locale, id: order.id
        }

        it "redirects to the previous url" do
          expect(response).to redirect_to(:back)
        end
      end

      context "when doesn't have 'cc' payment method" do
        let!(:order) {
          create(:order, :payment_chosen, account_id: user.account_id, user: user)
        }

        before {
			  	get :create, locale: locale, id: order.id
        }

        it "redirects to the previous url" do
          expect(response).to redirect_to(:back)
        end
      end
    end

    context "with valid permissions" do
      let(:address) { create(:address, account_id: user.account_id) }
      let!(:order) {
        create(:order,
          :payment_chosen,
          :cc_payment_method,
          account_id: user.account_id,
          user: user,
          address: address)
      }

      context "when it is a credit card purchase with error" do
        before {
          StripeMock.prepare_card_error(:card_declined)
				  get :create, locale: locale, id: order.id, stripeToken: stripe_helper.generate_card_token
        }

        it 'sets flash message' do
          expect(flash[:alert]).to eq(I18n.t(:card_rejected))
        end

        it "sets the order object" do
          expect(assigns(:address)).not_to be_nil
        end

        it "renders the order confirm action" do
				  expect(response).to render_template('signup/orders/confirm')
        end
      end

      context "when it is a successful credit card purchase" do
        let!(:event_booking_status) { create(:eventbookingstatus, :confirmed)}

        before {
				  get :create, locale: locale, id: order.id, stripeToken: stripe_helper.generate_card_token
        }

        it "redirects to the order detail" do
          expect(response).to redirect_to(signup_order_path(order))
        end
      end
    end
  end
end