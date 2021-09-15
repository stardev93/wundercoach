require "rails_helper"

RSpec.describe RegisterController, type: :controller do
	describe "#new" do
		let(:affiliate) { create(:affiliate) }

		context "with valid affiliate token" do
			it "displays a notice about the affiliate program" do
				post :new, locale: "de", token: affiliate.token

				expect(flash[:notice]).to eq(I18n.t('affiliate_participation', affiliate: affiliate.name))
				expect(assigns(:form)).to be_a(Account::RegistrationForm)
			end
		end

		context "with invalid affiliate token" do
			it "displays a notice about invalid token" do
				post :new, locale: "de", token: ''

				expect(flash[:notice]).to eq(I18n.t('invalid_token'))
				expect(assigns(:form)).to be_a(Account::RegistrationForm)
			end
		end
	end

	describe '#create' do
		before {
    	create(:paymentplan, :premium)
    	create(:vat)
			create(:role, :user)
		}

  	let(:account_params) {
			{
				name: "Test Company",
				firstname: "Max",
				lastname: "Mustermann",
				gender: 'male',
				creator_attributes: {
					email: "test1@test.com",
					password: "asdasdasd"
				}
    	}
		}

		context 'with valid params' do
			it "creates an account" do
				expect {
					post :create, locale: "de", account: account_params
				}.to change(Account, :count).by(1)
			end

			it "redirects to the registration-success page" do
				post :create, locale: "de", account: account_params

				expect(response).to redirect_to(register_success_path)
			end
		end
		
		context "with invalid params" do
			it "does not save the new account" do
      	expect {
        	post :create, locale: "de", account: {}
      	}.to_not change(Account, :count)
    	end

			it "renders the register template" do
				post :create, locale: "de", account: {}

				expect(response).to render_template(:new)
			end
		end
	end
end
