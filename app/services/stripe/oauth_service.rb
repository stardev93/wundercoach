module Stripe
  require 'oauth2'
  class OauthService
    def initialize(redirect_uri)
      @redirect_uri = redirect_uri
      @oauth = OAuth2::Client.new(
        ENV['stripe_client_id'],
        ENV['stripe_secret_key'],
        site: 'https://connect.stripe.com',
        authorize_url: '/oauth/authorize',
        token_url: '/oauth/token'
      )
    end

    # Step 1: Build url for sending users to gocardless
    def build_authorization_link
      @oauth.auth_code.authorize_url(
        redirect_uri: @redirect_uri,
        scope: 'read_write'
      )
    end

    # Step 2: When users return, fetch and return access_token
    def fetch_access_token(code)
      access_token = @oauth.auth_code.get_token(code)
      {
        stripe_access_token: access_token.token,
        stripe_publishable_key: access_token.params["stripe_publishable_key"],
        stripe_user_id: access_token.params["stripe_user_id"]
      }
    end
  end
end
