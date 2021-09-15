module Gocardless
  # Gocardless Integration for our customers
  class OauthController < ApplicationController
    skip_before_action :set_locale
    # redirects to gocardless
    def redirect
      if @account.gocardless_integrated?
        flash[:notice] = t(:sepa_already_activated)
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
                           alert: t(:gocardless_error_cancelled, error: params[:error_description])
      end
      @account.update!(oauth_service.fetch_access_token(params[:code]))
      Accountpaymentmethod.joins(:paymentmethod).find_or_create_by!(paymentmethod: Paymentmethod.find_by(key: "direct_debit"))
      redirect_to payment_url(subdomain: @account.subdomain), notice: t(:gocardless_successfully_integrated)
    end

    private

    def oauth_service
      OauthService.new(gocardless_oauth_callback_url(subdomain: EXTERNAL_SUBDOMAIN, locale: nil))
    end

    # Overwrite set_tenant_and_account, since this method would usually set a subdomain
    # We must provide one unified callback url for all accounts, which is why we can't use custom subdomains here
    def set_tenant_and_account
      @account = current_user.account
      set_current_tenant @account
    end
  end
end
