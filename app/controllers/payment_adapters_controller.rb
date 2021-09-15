class PaymentAdaptersController < ApplicationController
  load_and_authorize_resource
  before_action :set_paymentadapter, only: %i(destroy)

  layout "account" # render with account navigation

  rescue_from GoCardlessPro::Error do |exception|
    DeveloperMailer.failure_notice("#{exception.class.name}, account: #{@account.id}", exception.message).deliver_later
    render_gocardless_error_message("gocardless.error_message")
  end

  def index
    session[:account_settings_referer] = payment_account_url
  end

  # starts creating a direct debit mandate
  # POST /payment/sepa
  def gocardless_redirect
    start_redirect_flow(gocardless_success_url)
  end

  # last step of creating a direct debit mandate
  # GET /payment/sepa
  def gocardless_success
    # check if the users redirect_flow_id equals the id that we saved
    if params[:redirect_flow_id].present? && params[:redirect_flow_id] == @account.misc[:gc_redirect_flow_id]
      create_adapter!
      flash[:notice] = I18n.t(:direct_debit_integrated)
      render "index"
    else
      render_gocardless_error_message
    end
  end

  # starts both creating a direct debit mandate and a first paid booking
  # POST /payment/sepa/:plan_id
  def gocardless_checkout_redirect
    start_redirect_flow(gocardless_checkout_initiation_url(Paymentplan.find(params[:plan_id])))
  end

  # creates a direct debit mandate and a first paid booking in one turn
  # GET /payment/sepa/:plan_id
  def gocardless_checkout
    # check if the users redirect_flow_id equals the id that we saved
    if params[:redirect_flow_id].present? && params[:redirect_flow_id] == @account.misc[:gc_redirect_flow_id]
      create_adapter!
      create_booking!
      redirect_to ordersuccess_path, notice: I18n.t(:direct_debit_integrated)
    else
      render_gocardless_error_message
    end
  end

  # shown after some error occured while setting up a payment adapter
  # GET /payment/error
  def error
    render "payment_adapters/error", layout: "application"
    # Show some error message
  end

  # DELETE /payment/1
  def destroy
    current_tenant.payment_adapter = nil
    current_tenant.save!
    @paymentadapter.destroy
    redirect_to payment_account_path, notice: t(:payment_adapter_delete_successful)
  end

  private

  def render_gocardless_error_message(message = "gocardless.not_finished_message")
    @headline = "gocardless.error_occured"
    @message = message
    render "payment_adapters/error"
  end

  def create_booking!
    booking = InvoiceBooking.new(paymentplan: Paymentplan.find(params[:plan_id]))
    booking.succeed_booking!(Booking.current)
  end

  def create_adapter!
    adapter = GocardlessPaymentAdapter.new
    adapter.complete_redirect_flow!(session.id, @account.misc[:gc_redirect_flow_id])
    @account.payment_adapter = adapter
    @account.misc[:gc_redirect_flow_id] = nil
    @account.save!
  end

  def start_redirect_flow(success_url)
    adapter = GocardlessPaymentAdapter.new
    adapter.create_redirect_flow(session.id, success_url)
    @account.misc[:gc_redirect_flow_id] = adapter.redirect_flow_id
    @account.save!
    redirect_to adapter.redirect_flow_url
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_paymentadapter
    @paymentadapter = PaymentAdapter.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def paymentadapter_params
    params.require(:paymentadapter).permit(:id)
  end
end
