require "rails_helper"

RSpec.describe SessionsController, type: :controller do
	describe '#create' do
		before {
			ActsAsTenant.current_tenant = nil
		}

		context 'with valid params' do
			context 'when user is activated and have an account' do
				let(:user) { create(:user, :with_account, :activated) }

				before {
					request.host = "#{user.account.subdomain}.lvh.me"
				}

				it "redirects to the root url with subdomain" do
					@request.host = "#{user.account.subdomain}.lvh.me"
					post :create, locale: "de", email: user.email, password: 'test01'

					expect(response).to redirect_to(root_url(subdomain: user.account.subdomain))
				end
			end

			context 'when user is unactivated' do
				let(:user) { create(:user, :with_account) }

				before {
					request.host = "#{user.account.subdomain}.lvh.me"
				}

				it "renders the login template" do
					post :create, locale: "de", email: user.email, password: 'test01'

					expect(response).to render_template(:new)
					expect(flash[:notice]).to eq(I18n.t('internal_activation_needed'))
				end
			end

			context "when user doesn't have an account" do
				let(:user) { create(:user) }

				it "redirects to the root url with external subdomain" do
					post :create, locale: "de", email: user.email, password: 'test01'

					expect(response).to redirect_to(
							root_url(subdomain: EXTERNAL_SUBDOMAIN)
						)
				end
			end

			context "when the user has the role 'affiliate'" do
				let(:user) { create(:user, :with_account, :activated, :affiliate) }

				before {
  				request.host = "#{user.account.subdomain}.lvh.me"
				}

				it "redirects to the root url with external subdomain" do
					post :create, locale: "de", email: user.email, password: 'test01'

					expect(response).to redirect_to(
						affiliate_dashboard_url(subdomain: user.account.subdomain)
					)
				end
			end
		end

		context 'with invalid params' do
			let(:user) { create(:user, :with_account, :activated) }

			before {
  			request.host = "#{user.account.subdomain}.lvh.me"
			}

			it "renders the login template" do
				post :create, locale: "de", email: '', password: ''

				expect(response).to render_template(:new)
				expect(flash[:notice]).to eq(I18n.t('email_or_password_invalid'))
			end
		end
	end

	describe '#destroy' do
    let(:user) { create(:user, :with_account, :activated) }
		
		before {
			request.host = "#{user.account.subdomain}.lvh.me"
			login_user(user)
		}

    it "logout and redirect to the external subdomain" do
      delete :destroy, locale: 'de'

      expect(flash[:notice]).to eq(I18n.t('logged_out'))
			expect(response).to redirect_to(
				root_url(subdomain: EXTERNAL_SUBDOMAIN)
			)
    end
  end
end
