# Secret keys for stripe, configuration for stripe webhooks via StripeEvent
Rails.configuration.stripe = {
  publishable_key: ENV['stripe_publishable_key'],
  secret_key:      ENV['stripe_secret_key']
}
Stripe.api_key = ENV['stripe_secret_key']

StripeEvent.authentication_secret = ENV['stripe_webhook_secret']

StripeEvent.configure do |events|
  events.all do |event|
    stripe_logger = Logger.new(Rails.root.join("log", "stripe.log"))
    stripe_logger.info "STRIPE: #{event.type}:#{event.id}"
  end
end
