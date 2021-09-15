# Controller for processing order payments via sofort.com
class Signup::StripeController < ApplicationController
  before_action :set_order
  layout 'checkout'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to :back, alert: exception.message
  end

  # charges a credit card
  # POST /signup/stripe/1/
  def create
    authorize! :pay_with_stripe, @order
    @product = @order.product
    charge = Stripe::Charge.create({
      amount: @order.price_cents, # Amount in cents
      currency: @order.currency,
      source: params[:stripeToken],
      description: @product.name
    }, { stripe_account: @account.stripe_user_id })
    @order.stripe_charge_id = charge.id
    @order.status = :paid
    @order.confirm
    redirect_to signup_order_path(@order)
  rescue Stripe::CardError
    flash.now[:alert] = t(:card_rejected)
    @address = @order.address
    render 'signup/orders/confirm'
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
