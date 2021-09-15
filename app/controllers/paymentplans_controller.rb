class PaymentplansController < ApplicationController
  before_action :set_paymentplan, only: %i(chooseplan payment)
  authorize_resource
  # skip_authorization_check only: :accountdata

  # GET /paymentplans
  # def index
  #   @paymentplans = Paymentplan.page(params[:page])
  # end

  # shows only the enterprise plan, if it has been offered to the customer
  def enterprise
    @paymentplan = @account.paymentplan_offer
  end

  # GET /showplans
  def showplans
    session[:plan] = nil
    @paymentplans = Paymentplan.current_plans
  end

  def payment
    session[:plan] = @paymentplan.id
    unless @account.billing_data_completed?
      redirect_to accountdata_path, notice: t(:account_data_not_please_complete)
    end
    transition = Paymentplan.transition(@account.paymentplan, @paymentplan)
    unless @account.bookings.current.trial? || transition.possible?
      @error_message = transition.error_message
      render "booking_impossible"
    end
    @stripe_apdater = StripePaymentAdapter.last
    @gc_apdater = GocardlessPaymentAdapter.last
  end

  # POST /paymentplans/1/chooseplan
  # use this to switch plans. raises if we don't have a stripe user yet
  # this action requires a payment adapter
  def chooseplan
    @account.update!(payment_adapter: PaymentAdapter.find(params[:adapter])) if params[:adapter]
    booking =
      if @paymentplan.free?
        FreeBooking.new(paymentplan: @paymentplan)
      else
        InvoiceBooking.new(paymentplan: @paymentplan)
      end

    booking.succeed_booking!(Booking.current)
    redirect_to ordersuccess_path, notice: t(:assign_successful)
  end

  # shown after successful order processing
  def ordersuccess
    @paymentplan = Paymentplan.find(session[:plan])
  end

  # GET /paymentplans/accountdata
  def accountdata
    @account.email_billing_address = @account.email if @account.email_billing_address.blank?
    # session[:account_settings_referer] = request.env['HTTP_REFERER']
  end

  # GET /paymentplans/termsofservice
  # display the generale terms of service in checkout
  def termsofservice
    pdf_filename = File.join(Rails.root, "/app/assets/files/Wundercoach_Nutzungsbedingungen.pdf")
    send_file(pdf_filename, filename: "Wundercoach_Nutzungsbedingungen.pdf", type: "application/pdf")
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_paymentplan
    @paymentplan = Paymentplan.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def paymentplan_params
    params.require(:paymentplan).permit(:name, :comments, :key, :price, :sortorder, :discount, :description, :recommended, :cycle)
  end

  def chooseplan_params
    params.permit(:type)
  end
end
