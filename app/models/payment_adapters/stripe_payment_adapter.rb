# Handles Stripe Payment for Account
class StripePaymentAdapter < PaymentAdapter
  def self.model_name
    PaymentAdapter.model_name
  end

  validates :stripe_customer, presence: true

  # charges a billing period, returns charge id
  # this is supposed to run in a background process (usually inside BillingPeriod#charge),
  # so that delayed job will automatically retry charging if an error occurs.
  def charge!(cents, idempotency_key)
    charge = Stripe::Charge.create({
      amount: cents,
      currency: "eur",
      customer: stripe_customer
    }, {
      idempotency_key: idempotency_key
    })
    { stripe_charge_id: charge.id, paymentmethod: payment_info }
  rescue Stripe::CardError => e
    # Since it's a decline, Stripe::CardError will be caught
    # Repeating this request will raise the same exception again.
    # In this case, we must notify the customer, that his card is invalid and
    # eventually put him on the free plan
    send_failure_mail(e)
    raise e
  rescue Stripe::InvalidRequestError => e
    # Invalid parameters were supplied to Stripe's API
    # this can only be fixed by a developer, send an error email
    send_failure_mail(e)
    raise e
  rescue Stripe::AuthenticationError => e
    # Authentication with Stripe's API failed
    # (maybe you changed API keys recently)
    # this can only be fixed by a developer, send an error email
    send_failure_mail(e)
    raise e
  rescue Stripe::RateLimitError => e
    # Too many requests made to the API too quickly
    # try again later. We should also check why we make so many requests
    raise e
  rescue Stripe::APIConnectionError => e
    # Network communication with Stripe failed
    # try again later.
    raise e
  rescue Stripe::StripeError => e
    # Catch all Stripe Errors
    send_failure_mail(e)
    raise e
  end

  # creates a stripe customer, which we charge regularly
  # may raise a Stripe::StripeError
  def save_stripe_customer!(token)
    customer = Stripe::Customer.create source: token,
                                       email: account.email
    credit_card = customer.sources.data.first # fetches the first card
    assign_attributes stripe_customer: customer.id,
                      payment_info: "#{credit_card.brand} ···· #{credit_card.last4}"
    save!
  end

  private

  # TODO: Fill this with logic
  def send_failure_mail(_e)
    # body = e.json_body
    # err  = body[:error]
    # DeveloperMailer.failure_notice(err[:type], err[:message]).deliver_later
  end
end
