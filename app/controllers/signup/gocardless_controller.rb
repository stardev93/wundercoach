# Controller for processing order payments via gocardless
class Signup::GocardlessController < ApplicationController
  before_action :set_order
  layout 'checkout'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to signup_index_path, alert: exception.message
  end

  # starts creating a direct debit mandate
  # POST /signup/sepa/1
  def redirect
    @order.assign_attributes(order_params)
    if @order.valid?
      Gocardless::RedirectFlowService::Initialize.run(@order) do |redirect_url|
        return redirect_to redirect_url
      end
    else
      @address = @order.address
      @product = @order.product.decorate
      @order = @order.decorate
      render 'signup/orders/confirm'
    end
  end

  # last step of creating a direct debit mandate
  # GET /signup/sepa/1?redirect_flow_id=RE00008PWPJHW1HAHA241ECARQNZXVZM
  def success
    return unless params[:redirect_flow_id] == @order.gocardless_redirect_flow_id
    Gocardless::RedirectFlowService::CreateMandate.run(@order) do
      Gocardless::Payment.run(@order) do
        @order.status = :paid
        @order.confirm
        return redirect_to signup_order_path(@order)
      end
      # Payment failed
    end
    # Payment or creating mandate failed
  end

  private

  def order_params
    if params[:order]
      params.require(:order).permit(:terms_of_service, :gdpr_terms, :revocation_terms)
    else
      {}
    end
  end

  def set_order
    @order = Order.find(params[:id])
  end
end
