# Implements a Checkout for any product
# Responsible for checkout only, no payment or product presentation
class Signup::OrdersController < ApplicationController
  before_action :set_order, except: %i(set_payment)
  authorize_resource
  before_action :decorate_order, only: %i(edit update payment confirm show)

  layout 'checkout'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to signup_index_path, alert: exception.message
  end

  # Checkout Step 1
  # This is where you edit contact data
  # GET /signup/orders/1/contact
  # this is aliased in routes.rb: /signup/orders/1/contact means /signup/orders/1/edit
  # WTF? 
  def edit
    @order.address ||= Address.new
    @order.billing_address ||= Address.new

    # do we have multipricing enabled?
    if @order.product&.multipricing?
      @order.price_cents = @order.product.pricingset.get_preset.price_cents(@order.product)
      @order.pricingoption = @order.product.pricingset.get_preset.id
      @order.pricingoptiontext = @order.product.pricingset.get_preset.name

    end
  end

  # Checkout Step 1->2
  # Validates and saves valid contact and billing data
  # and maybe also product specific stuff
  # PATCH/PUT /signup/orders/1
  def update
    @product = @order.product
    if @order.update(order_params)
      @order.data_completed! if @order.just_started?
      @order.payment_chosen! if @order.data_completed? && @order.paymentmethod
      next_action = @product.free? ? 'confirm' : 'payment'
      redirect_to(action: next_action, id: @order.id)
    else
      @order.address ||= Address.new
      @order.billing_address ||= Address.new
      render action: 'edit'
    end
  end

  # Checkout Step 2
  # action to choose payment options if online payment is active
  # GET /signup/orders/1/payment
  def payment
    @product = @order.product.decorate
  end

  # Checkout Step 2->3
  # POST /signup/orders/1/set_payment
  def set_payment
    result = Order::SetPayment.call(params)
    if result.success?
      redirect_to(action: 'confirm', id: result['model'].id)
    else
      flash.now[:notice] = t(:choose_a_paymentmethod)
      @order = result['model'].decorate
      @product = @order.product.decorate
      render 'payment'
    end
  end

  # Checkout Step 3
  # Show booking data and confirm button
  # GET /signup/backen-ohne-mehl/1/confirm
  def confirm
    @address = @order.address
    @product = @order.product.decorate
  end

  # Checkout Step 3 -> Finished!
  # Standard and Free Events
  # POST /signup/backen-ohne-mehl/1/confirm leads here
  def final_confirm
    @product = @order.product.decorate
    @order.assign_attributes(confirmation_params)

    # this is where the magic happens: execute all steps to confirm the order.
    @order.confirm
    redirect_to(action: 'show', id: @order.id)
  rescue ActiveRecord::RecordInvalid
    #flash[:alert] = t(:please_check_for_errors)
    @order = @order.decorate
    @address = @order.address
    render 'confirm'
  end

  # Thank you action
  def show
    @address = @order.address
    @product = @order.product.decorate
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def decorate_order
    @order = @order.decorate
  end

  def confirmation_params
    return {} if !current_tenant.terms_required || @product.free?
    params.require(:order).permit(:terms_of_service, :gdpr_terms, :revocation_terms)
  end

  def order_params
    all_params = params.require(:order).permit(:price_cents, :pricingoption, :pricingoptiontext, :client_order_info,
      address_attributes: Address::FORM_ATTRIBUTES, billing_address_attributes: Address::FORM_ATTRIBUTES,
      additional_participants: %i(firstname lastname gender)
    )
    unless params[:different_billing_address].present?
      all_params.delete(:billing_address_attributes)
    end
    all_params
  end
end
