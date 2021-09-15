class Order < ActiveRecord::Base
  # Form for setting payment data, (signup step 2)
  class PaymentForm < Reform::Form
    property :paymentmethod_id
    property :client_order_info
    
    validates :paymentmethod_id, presence: true
  end
end
