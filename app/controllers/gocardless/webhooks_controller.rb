require 'openssl'
# This controller recieves and processes Webhooks from Gocardless
class Gocardless::WebhooksController < ApplicationController
  include ActionController::Live
  skip_authorization_check
  skip_before_action :set_locale, :require_login, :set_tenant_and_account
  protect_from_forgery except: :create

  def create
    secret = ENV['gocardless_webhook_secret']
    computed_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
                                                 secret,
                                                 request.raw_post)
    provided_signature = request.headers['Webhook-Signature']

    if Rack::Utils.secure_compare(provided_signature, computed_signature)
      head :ok
    else
      head 498
    end
  end
end
