# Controller for processing order payments via sofort.com
class Signup::PaypalController < ApplicationController
  before_action :set_order
  layout 'checkout'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to :back, alert: exception.message
  end

  # charges a credit card
  # POST /signup/stripe/1/
  def create
    authorize! :pay_with_paypal, @order
    @product = @order.product

    if params[:paypalStatus] == "COMPLETED"
       @order.paypal_charge_id = params[:paypalChargeID]
      @order.status = :paid
      @order.confirm
      redirect_to signup_order_path(@order)
    else
      flash.now[:alert] = t(:card_rejected)
      @address = @order.address
      render 'signup/orders/confirm'
    end
 
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
