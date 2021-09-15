module Gocardless
  require 'oauth2'
  class Payment < Order
    def run
      payment = @client.payments.create(
        params: {
          amount: @order.amount,
          currency: @order.currency,
          links: {
            mandate: @order.mandate
          }
        },
        headers: {
          'Idempotency-Key' => @order.idempotency_key
        }
      )
      @order.update!(gocardless_payment_id: payment.id, status: :paid)
      yield @order
    end
  end
end
