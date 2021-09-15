module Stripe
  # Stripe Connect Integration for our Customers
  class OauthController < ApplicationController
    skip_before_action :set_locale
    # redirects to gocardless
    def redirect
      if @account.stripe_integrated?
        flash[:notice] = "Stripe wurde bereits aktiviert"
        redirect_to :back
      else
        redirect_to oauth_service.build_authorization_link
      end
    end

    # When returning from gocardless, this callback is executed.
    # the customer has now integrated gocardless!
    def callback
      if params[:error] == "access_denied"
        return redirect_to payment_url(subdomain: @account.subdomain),
                           alert: %(Der Vorgang wurde abgebrochen. Fehlermeldung von Stripe: "#{params[:error_description]}")
      end
      @account.update!(oauth_service.fetch_access_token(params[:code]))
      Accountpaymentmethod.joins(:paymentmethod).find_or_create_by!(paymentmethod: Paymentmethod.find_by(key: "cc"))
      redirect_to payment_url(subdomain: @account.subdomain), notice: "Stripe wurde erfolgreich integriert!"
    end

    private

    def oauth_service
      OauthService.new(stripe_oauth_callback_url(subdomain: EXTERNAL_SUBDOMAIN, locale: nil))
    end

    # Overwrite set_tenant_and_account, since this method would usually set a subdomain
    # We must provide one unified callback url for all accounts, which is why we can't use custom subdomains here
    def set_tenant_and_account
      @account = current_user.account
      set_current_tenant @account
    end
  end
end
