class Account < ApplicationRecord
  # Updates Paypal.com access. Only allows complete data access data
  class UpdatePaypal < Trailblazer::Operation
    step Contract::Build(constant: PaypalForm)
    step Contract::Validate()
    step Contract::Persist()
  end
end
