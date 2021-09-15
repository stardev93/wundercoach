# Controller for processing order payments via sofort.com
class Signup::SofortController < ApplicationController
  before_action :set_order
  layout 'checkout'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to signup_index_path, alert: exception.message
  end

  # creates a new transaction and redirects to sofort.com
  # POST /signup/sofort/1/
  def create
    authorize! :pay_with_sofort, @order
    @order.assign_attributes(confirmation_params)
    unless @order.valid?
      @order = @order.decorate
      @address = @order.address
      @product = @order.product.decorate
      return render 'signup/orders/confirm'
    end
    # TODO: check if chosen paymentmethod is sofort. sofort payment must be available for this event
    transaction = ::Sofort::StartTransaction.new(@order)
    transaction.run do |sofort_checkout|
      return redirect_to sofort_checkout
    end
    # TODO: Handle case of Transaction not working
    # render 'something'
  end

  # sofort.com redirects here after successful transaction.
  # finishes sofort-transaction and shows thankyou page
  # GET /signup/sofort/1/1234-1234-1234-1234
  def success
    authorize! :view_sofort_thankyou_page, @order
    @address = @order.address
    @product = @order.product.decorate
    return render 'signup/orders/show' if @order.confirmed?
    transaction = ::Sofort::FinishTransaction.new(@order)
    transaction.run do
      @order.status = :paid
      @order.confirm
      return render 'signup/orders/show'
    end
    # customer opens success-page, but transaction is not complete
    flash.now[:notice] = t(:transaction_no_confirmation)
    render 'signup/orders/show'
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def confirmation_params
    if params[:order]
      params.require(:order).permit(:terms_of_service, :gdpr_terms, :revocation_terms)
    else
      {}
    end
  end
end
