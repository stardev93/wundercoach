class Order < ActiveRecord::Base
  # Create an Order from the backend
  class Create < Trailblazer::Operation
    step Model(Order, :new)
    step :setup!
    step Contract::Build(constant: CreateForm)
    step Contract::Validate()
    step :set_status!
    step Contract::Persist()
    step :process_order!
    failure :populate_billing_address!

    private

    def set_status!(options, params:, **)
      paymentmethod = Paymentmethod.find_by_id(params[:paymentmethod_id])
      options['model'].status = paymentmethod.key == 'vorkasse' ? :waiting_for_payment : :confirmed
    end

    def setup!(options)
      options['model'].order_date = Time.now
      options['model'].product = options['product']
    end

    # call create_eventbooking method of product (i.e. Event, BundleEvent etc.)
    def process_order!(options)
      options['product'].create_eventbooking(options['model'])
    end

    # Ensure we have a billing_address in our form after the operation failed
    def populate_billing_address!(options)
      options['contract.default'].billing_address ||= Address.new
    end
  end
end
