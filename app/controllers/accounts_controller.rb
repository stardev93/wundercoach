# Handles all kinds of account related settings
class AccountsController < ApplicationController
  skip_authorize_resource # authorization is handled individually for each method
  layout 'account'

  # GET /account
  def show
    authorize! :read, @account
  end

  # GET /editsettings
  def editsettings
    authorize! :update, @account
  end

  # GET /editsettings
  def generatetoken
    authorize! :update, @account
    @account.token = SecureRandom.uuid
    @account.save!
    redirect_to settings_path, notice: t(:token_generation_successful)
  end

  # GET /design
  def design
    authorize! :read, @account
  end

  # GET /designedit
  def designedit
    authorize! :update, @account
  end

  # GET /toggleheaderimage
  def toggleheaderimage
    authorize! :update, @account
    @account.show_header_image = !@account.show_header_image
    @account.save!
    redirect_to event_design_path
  end

  # GET /domainsettings
  def domainsettings
    authorize! :read, @account
  end

  # GET /domainsettingsedit
  def domainsettingsedit
    authorize! :update, @account
  end

  # GET /invoicedesign
  def invoicedesign
    authorize! :read, @account
  end

  # GET /invoicedesignedit
  def invoicedesignedit
    authorize! :update, @account
  end

  # GET /accounts/accountlogoremove
  def accountlogoremove
    authorize! :update, @account
    @account.logo.destroy
    @account.save!
    redirect_to design_path, notice: t(:account_logo_successfully_deleted)
  end

  # GET /accounts/eventdesignremove
  def eventdesignremove
    authorize! :update, @account
    @account.eventheader.destroy
    # @account.eventheader.clear
    @account.save!
    redirect_to event_design_path, notice: t(:headerimage_successfully_deleted)
  end

  # GET /invoicelogoremove
  def invoicelogoremove
    authorize! :update, @account
    @account.invoicelogo.destroy
    @account.save!
    redirect_to invoicedesign_path, notice: t(:invoicelogo_successfully_deleted)
  end

  # GET /invoicefooterremove
  def invoicefooterremove
    authorize! :update, @account
    @account.invoicefooter.destroy
    @account.save!
    redirect_to invoicedesign_path, notice: t(:invoicelogo_successfully_deleted)
  end

  # GET /history
  def history
    authorize! :read, @account
    @current_booking = @account.bookings.current
  end

  # GET /billing
  def billing
    authorize! :read, @account
    @billing_periods = @account.billing_periods
  end

  # GET /payment
  def payment
    authorize! :read, @account
    @accountpaymentmethods = @account.accountpaymentmethods
  end

  # GET /accounts/signup
  def welcome
    redirect_to root_path
    authorize! :read, @account
  end

  # GET /account/edit
  def edit
    authorize! :manage, Account
  end

  # PATCH/PUT /account
  def update
    authorize! :update, @account
    # TODO: substitue validation flag with form object
    # @account.check_billing_data = true
    if @account.update(account_params)
      # TODO: add all possible referers
      action =
        case request.referer
        when /domainsettingsedit/ then domainsettings_path
        when /invoicedesignedit/ then invoicedesign_path
        when /seosettingsedit/ then seosettings_path
        when /payment/ then payment_account_path
        else account_path
        end
      redirect_to action
    else
      # TODO: add all possible referers
      action =
        case request.referer
        when /domainsettingsedit/ then 'domainsettingsedit'
        when /invoicedesignedit/ then 'invoicedesignedit'
        else 'show'
        end
      render action: action
    end
  end

  # PATCH /accounts/updateshort
  def updateshort
    authorize! :update, @account
    @account.check_billing_data = true
    if @account.update(account_params)
      redirect_to payment_paymentplan_path(session[:plan].to_i)
    else
      render template: 'paymentplans/accountdata', layout: 'application'
    end
  end

  # PATCH /domainsettings
  def domainsettingsupdate
    authorize! :update, @account
    if @account.update(account_params)
      redirect_to domainsettings_path, notice: t(:account_successfully_updated)
    else
      flash[:notice] = @account.errors.messages
      render template: 'accounts/domainsettingsedit'
    end
  end

  # GET /accounts/seosettings
  def seosettings
    authorize! :read, @account
  end

  # GET /seosettingsedit
  def seosettingsedit
    authorize! :update, @account
  end

  # GET /account/confirm_delete
  def confirm_delete
    authorize! :destroy, @account
  end

  # DELETE /account
  def destroy
    authorize! :destroy, @account
    # check if user confirmed with his account number
    raise ActiveRecord::RecordNotDestroyed, 'account.delete_confirmation_error' unless delete_confirm_params[:delete_confirmation] == @account.accountnumber.to_s
    @account.deactivate
    logout
    redirect_to login_url, notice: t(:account_successfully_deleted)
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to :back, alert: I18n.t(e.message)
  end

  # iframe editor
  def iframe
    authorize! :read, @account
  end

  def togglewebsiteintegration
    authorize! :update, @account
    @account.websiteintegration_done = !@account.websiteintegration_done
    @account.save
    redirect_to iframe_path
  end

  # GET /domainsettings
  def smtpserversettings
    authorize! :read, @account
    @smtpservers = Smtpserver.all
    if @smtpservers.length != 2
      Smtpserver.populate(@account)
      redirect_to smtpserversettings_path
    end
    @smtpserver = @account.get_smtp_server
    # @dnssettings = @smtpserver.testconnection("TXT")
  end

  # GET /domainsettingsedit
  def smtpserversettingsedit
    authorize! :update, @account
    @smtpserver = Smtpserver.find(params[:id])
    @form = Smtpserver::SmtpserverForm.new(@smtpserver)
    # @smtpserver.from_name = @account.name if @smtpserver.from_name.blank?
    # @smtpserver.replyto_address = @account.email if @smtpserver.replyto_address.blank?

  end

  private

  def delete_confirm_params
    params.require(:account).permit(:delete_confirmation)
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(
      :name, :name_addon, :comments, :zip, :notification_url, :robots_txt,
      :city, :street, :streetno, :country, :gender, :firstname, :lastname,
      :tel1, :tel2, :fax, :email, :homepage, :logo, :payment_adapter_id,
      :email_billing_address, :accountstatus_id, :landingpagecode,
      :vat_number, :invoice_no_start, :subdomain, :token, :vat_included, :vat_net_first,
      :eventheader, :invoice_from_small, :websiteintegration_done,
      :invoice_from, :invoice_footer, :tax_id, :invoicelogo, :invoicelogo_alignment, :invoicefooter, :domain, :active,
      :tracking_code, :tracking_code_location, :tracking_code_active, :favicon, :default_vat_id, :default_currency_iso_code, :cancellation_no_start,
      :order_no_start, :order_confirmation_no_start, :quote_no_start, :accounts_chart, :tax_consultant_id,
      :tax_consultant_client_id, :fiscal_year_start_day, :fiscal_year_start_month, :fiscal_year_end_day, :fiscal_year_end_month, :export_fixed_at_start_date,
      :export_fixed_at_end_date, :revenue_account, :account_receivable_no_start, :account_receivable_autonumbering, :time_zone,
      :costcenter, :gdpr_required, :gdpr_link, :gdpr_link_text, :revocation_required, :revocation_link, :revocation_link_text, vat_country_ids: []
    )
  end
end
