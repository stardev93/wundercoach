require "rails_helper"

RSpec.describe Signup::EventsController, type: :controller do
	let(:locale) { 'de' }
	let(:user) { create(:user) }

  describe '#show' do
    before {
		  request.host = "#{user.account.subdomain}.lvh.me"
	  	login_user(user)
    }
    
		context "with a valid account" do
			let(:event_type) { create(:eventtype) }
			let!(:events) { create_list(:event, 3, account_id: user.account_id, eventtype: event_type) }

			before {
				get :show, locale: locale, slug: events[0].slug
			}

			it "assigns the @account" do
				expect(assigns(:account)).to_not be_nil
			end

			it "assigns the @event" do
				expect(assigns(:event)).to_not be_nil
			end

			it "renders show template" do
				expect(response).to render_template(:show)
			end

			it "renders signup_full_width layout" do
				expect(response).to render_template("layouts/signup_full_width")
			end
		end

		context "with invalid event" do
			before {
				get :show, locale: locale, slug: 'invalid-event'
			}

			it "redirects to signup listing" do
				expect(response).to redirect_to(signup_index_url)
			end
		end
	end

	describe "#create_order" do
		let!(:event) { create(:event, account_id: user.account_id) }

		before {
			request.host = "#{user.account.subdomain}.lvh.me"
			login_user(user)

			post :create_order, locale: locale, slug: event.slug
    }

		it "builds @order object" do
			expect(assigns(:order)).to_not be_nil
		end

		context "when event is free" do
			let(:payment_method) { create(:paymentmethod, :free) }
			let!(:event) { create(:event, account_id: user.account_id, paymentmethods: [payment_method]) }

			it "has free payment method" do
				expect(assigns(:order).paymentmethod).to eq(payment_method)
			end
		end

		it "redirects to edit signup order template" do
			order = assigns(:order)
			expect(response).to redirect_to(edit_signup_order_path(order))
		end
	end
end
