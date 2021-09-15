class Admin::PaymentAdaptersController < Admin::AdminController
  before_action :set_payment_adapter, only: %i(destroy, edit)

  layout "account" # render with account navigation

  # GET /payment_adapters/1/edit
  def edit
    @payment_adapter = PaymentAdapter.find(params[:id])
  end

  # DELETE /payment_adapters/1
  def destroy
    #ActsAsTenant.without_tenant do
    @payment_adapter = PaymentAdapter.find(params[:id])
    @account = @payment_adapter.account
    if @account.payment_adapter_id == @payment_adapter.id
      @account.payment_adapter = nil
      @account.save
    end
    @payment_adapter.destroy
    #end
    redirect_to admin_account_path(@account) + "#payment_adapters", notice: t(:delete_successful)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_payment_adapter
    @payment_adapter = PaymentAdapter.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def payment_adapter_params
    params.require(:payment_adapter).permit(
      :account_id, :type, :stripe_customer, :created_at, :updated_at, :gocardless_mandate_id, :payment_info
    )
  end
end
