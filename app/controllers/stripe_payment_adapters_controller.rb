class StripePaymentAdaptersController < ApplicationController
  load_and_authorize_resource

  rescue_from Stripe::CardError do |exception|
    @message = "stripe.card_error.#{exception.code}"
    handle_error(exception)
  end

  rescue_from Stripe::RateLimitError, Stripe::APIConnectionError, with: :try_again_later
  rescue_from Stripe::InvalidRequestError, Stripe::AuthenticationError, with: :we_take_care_of_it

  # POST /stripe_payment_adapters
  def create
    create_adapter!
    redirect_to payment_account_path, notice: I18n.t(:creditcard_integrated)
  end

  # Creates an Adapter and uses it to book a plan
  # POST /stripe_checkout/:plan_id
  def checkout
    create_adapter!
    booking = StripeBooking.new(paymentplan: Paymentplan.find(params[:plan_id]))
    booking.succeed_booking!(Booking.current)
    redirect_to ordersuccess_path
  end

  private

  def create_adapter!
    adapter = StripePaymentAdapter.new
    adapter.save_stripe_customer! params[:stripeToken] # may raise Stripe::StripeError
    @account.update! payment_adapter: adapter
  end

  # Error handling methods
  def we_take_care_of_it(exception)
    @message = "stripe.we_take_care_of_it"
    handle_error(exception)
  end

  def try_again_later(exception)
    @message = "stripe.try_again_later"
    handle_error(exception)
  end

  def handle_error(exception)
    DeveloperMailer.failure_notice("#{exception.class.name}, account: #{@account.id}", exception.message).deliver_later
    @headline = "stripe.an_error_occured"
    render "payment_adapters/error"
  end
end
