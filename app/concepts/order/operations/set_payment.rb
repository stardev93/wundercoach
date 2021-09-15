class Order < ActiveRecord::Base
  # Implements Step 2 of the Signup Process
  # assumes a valid order and sets its paymentmethod
  class SetPayment < Trailblazer::Operation
    step Model(Order, :find_by)
    step Contract::Build(constant: PaymentForm)
    step Contract::Validate(key: 'order')
    step :status!
    step Contract::Persist()

    private

    def status!(options)
      options['model'].status = :payment_chosen
    end
  end
end
