require "rails_helper"

RSpec.describe Signup::GocardlessController, type: :controller do
  let(:locale) { 'de' }
  let(:user) { create(:user) }
  let(:address) { create(:address, account_id: user.account_id) }
  let(:order) {
    create(:order,
      :gocardless_payment_method,
      account_id: user.account_id,
      user: user,
      address: address)
  }
  let!(:order_decorated) { Gocardless::OrderDecorator.decorate(order) }

  ENV['gocardless_environment'] = "sandbox"

  describe '#redirect' do
    before {
      request.host = "#{user.account.subdomain}.lvh.me"
	    login_user(user)
    }

    context "with invalid order" do
      before {
        allow_any_instance_of(Order).to receive(:valid?).and_return(false)

        post :redirect, locale: locale, id: order.id
      }

      it "sets the address object" do
        expect(assigns(:address)).not_to be_nil
      end

      it "sets the product object" do
        expect(assigns(:product)).not_to be_nil
      end

      it "sets the order object" do
        expect(assigns(:order)).not_to be_nil
      end

      it 'renders confirm template' do
        expect(response).to render_template('signup/orders/confirm')
      end
    end

    context "with valid order" do
      context "receives the redirect url" do
        let(:response_body) {
          {
            redirect_flows: {
              description: order_decorated.description,
              id: 'id-input',
              redirect_url: "https://pay.gocardless.com/flow/RE-Dummy",
              session_token: order_decorated.session_token
            }
          }.to_json
        }

        before {
          stub_request(:post, "https://api-sandbox.gocardless.com/redirect_flows")
            .with(body: { 
              redirect_flows: {
                description: order_decorated.description,
                session_token: order_decorated.session_token,
                success_redirect_url: order_decorated.success_redirect_url
              }
            })
            .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

            post :redirect, locale: locale, id: order.id
        }

        it "sets the order object" do
          expect(assigns(:order)).not_to be_nil
        end

        it "sets the gocardless_redirect_flow_id" do
          expect(assigns(:order).gocardless_redirect_flow_id).to eq("id-input")
        end

        it "redirects to Gocardless url" do
          expect(response).to redirect_to("https://pay.gocardless.com/flow/RE-Dummy")
        end
      end
    end
  end

  describe '#success' do
    let(:order) {
      create(:order,
        :gocardless_payment_method,
        :gocardless_redirect_flow_id,
        account_id: user.account_id,
        user: user,
        address: address)
    }

    before {
      request.host = "#{user.account.subdomain}.lvh.me"
	    login_user(user)
    }

    context "with valid redirect_flow_id" do
      let!(:event_booking_status) { create(:eventbookingstatus, :confirmed)}
      let!(:order_decorated) { Gocardless::OrderDecorator.decorate(order) }
  
      before {
        stub_request(:post, "https://api-sandbox.gocardless.com/redirect_flows/#{order_decorated.gocardless_redirect_flow_id}/actions/complete")
          .with(body: {
            data: {
              session_token: order_decorated.session_token
            }
          })
          .to_return(status: 200, body: {
            redirect_flows: {
              links: {
                mandate: "mandate_id"
              },
              confirmation_url: "http://confimation.url"
            }
        }.to_json, headers: { 'Content-Type' => 'application/json' })
            
        stub_request(:post, "https://api-sandbox.gocardless.com/payments")
          .with(body: {
            payments: {
              amount: order_decorated.amount,
              currency: order_decorated.currency,
              links: {
                mandate: 'mandate_id'
              }
            }
          })
          .to_return(status: 200, body: {
            payments: {
              id: "PM0002",
              status: "confirmed",
              created_at: Time.zone.now
            }
          }.to_json, headers: { 'Content-Type' => 'application/json' })

        get :success, locale: locale, id: order.id, redirect_flow_id: order.gocardless_redirect_flow_id
      }

      it "sets the order object" do
        expect(assigns(:order)).not_to be_nil
      end

      it "sets the order object" do
        expect(assigns(:order).status).to eq("paid")
      end

      it "sets the gocardless_payment_id" do
        expect(assigns(:order).gocardless_payment_id).to eq("PM0002")
      end

      it "rerdirects to order path" do
        expect(response).to redirect_to(signup_order_path(order))
      end
    end
  end
end