class Admin::BillingPeriodsController < Admin::AdminController
  before_action :set_billing_period, only: %i(destroy)
  authorize_resource

  # DELETE /billing_periods/1
  def destroy
    @account = @billingperiod.account
    @billingperiod.accountinvoicepositions.delete_all
    @billingperiod.accountinvoice&.destroy
    @billingperiod.destroy
    redirect_to admin_account_path(@account) + '#billing_periods', notice: t(:delete_successful)
  end

  def edit
  end

  def update
  end

  def create
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_billing_period
    @billingperiod = BillingPeriod.find(params[:id])
  end

end
