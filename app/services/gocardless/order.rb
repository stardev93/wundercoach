module Gocardless
  # Base Class for Operation working on orders
  class Order
    # create and run instance
    def self.run(order, &block)
      service = new(order)
      service.run(&block)
    end

    protected

    # sets @order and @client
    def initialize(order)
      @order = Gocardless::OrderDecorator.new(order)
      @client = GoCardlessPro::Client.new({
        access_token: @order.access_token,
        environment: ENV['gocardless_environment'].to_sym
      })
    end
  end
end
