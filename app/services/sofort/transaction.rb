module Sofort
  # For Handling the sofort.com API
  class Transaction
    require "uri"
    require "net/http" # Ruby standard class for sending http request

    SOFORT_ENDPOINT = URI("https://api.sofort.com/api/xml")

    # prepare request (Uri, auth, request)
    def initialize(order)
      @order = Payment::SofortDecorator.new(order)
      prepare_request
    end

    protected

    # sends any kind of request to sofort. request must already be prepared
    def send_request
      log @request.body
      Net::HTTP.start(*@request_args) do |http|
        http.request @request
      end
    end

    def log(content)
      Rails.logger.info content if ENV["RAILS_ENV"] == "development"
    end

    def debug(content)
      Rails.logger.debug content if ENV["RAILS_ENV"] == "development"
    end

    private

    # sets up everything for making requests, except from the request-body
    def prepare_request
      @request = Net::HTTP::Post.new(SOFORT_ENDPOINT)
      @request["Accept"] = "application/xml"
      @request["Content-Type"] = "application/xml"
      @request.basic_auth(@order.user_id, @order.api_key)
      @request_args = [SOFORT_ENDPOINT.host, Net::HTTP.https_default_port, use_ssl: true]
    end
  end
end
