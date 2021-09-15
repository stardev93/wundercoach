module Gocardless
  require 'oauth2'
  class OauthService
    def initialize(redirect_uri)
      @redirect_uri = redirect_uri
      @oauth = OAuth2::Client.new(
        ENV['gocardless_client_id'],
        ENV['gocardless_client_secret'],
        site: ENV['gocardless_oauth_api_url'],
        authorize_url: '/oauth/authorize',
        token_url: '/oauth/access_token'
      )
    end

    # Step 1: Build url for sending users to gocardless
    def build_authorization_link
      @oauth.auth_code.authorize_url(
        redirect_uri: @redirect_uri,
        scope: 'read_write',
        initial_view: 'signup'
      )
    end

    # Step 2: When users return, fetch and return access_token
    def fetch_access_token(code)
      access_token = @oauth.auth_code.get_token(
        code,
        redirect_uri: @redirect_uri
      )
      { gocardless_access_token: access_token.token,
        gocardless_organisation_id: access_token['organisation_id'] }
    end
  end
end
