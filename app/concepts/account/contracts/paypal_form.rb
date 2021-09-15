class Account < ApplicationRecord
  # Form for updating and validating the account's paypal.com access data
  class PaypalForm < Reform::Form
    property :paypal_client_id

    validates :paypal_client_id, presence: true
  end
end
