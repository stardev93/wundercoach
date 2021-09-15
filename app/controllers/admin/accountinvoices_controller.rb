class Admin::AccountinvoicesController < Admin::AdminController
  before_action :set_accountinvoice, only: %i(show edit update destroy pdf cancel sendaccountinvoice download createnew)
  authorize_resource

  # GET /accountinvoices
  def index

    - beginning_of_next_year = ((Date.today + 1.year).in_time_zone("Europe/Berlin").beginning_of_year).to_datetime.to_s
    - end_of_next_year = ((Date.today + 1.year).in_time_zone("Europe/Berlin").end_of_year).to_datetime.to_s

    session[:q] ||= Hash.new
    session[:q]['invoice_date_gteq'] ||= Date.today.to_s  + 'T00:00:00'
    session[:q]['invoice_date_lteq'] ||= ''
    session[:q]['recipient_name_1_cont'] ||= ''
    session[:q]['invoice_number_eq'] ||= ''

    # when reset button is pressed
    if params['filter'] == 'reset'
      session[:q] = Hash.new
      session[:q]['invoice_date_gteq'] = ''
      session[:q]['invoice_date_lteq'] = ''
      session[:q]['recipient_name_1_cont'] = ''
      session[:q]['invoice_number_eq'] ||= ''
    end

    if params[:q]
      if !params[:q]['invoice_date_gteq'].nil? && params[:q]['invoice_date_gteq'] != '' && params[:q]['invoice_date_gteq'].length == 10
        params[:q]['invoice_date_gteq'] = params[:q]['invoice_date_gteq'] + 'T00:00:00'
      end
      if !params[:q]['invoice_date_lteq'].nil? && params[:q]['invoice_date_lteq'] != '' && params[:q]['invoice_date_lteq'].length == 10
        params[:q]['invoice_date_lteq'] = params[:q]['invoice_date_lteq'] + 'T23:59:59'
      end
      session[:q] = session[:q].merge(params[:q])
    end

    @q = Accountinvoice.includes(:accountinvoicetype).includes(:account).ransack(session[:q])
    @q.sorts = ['invoice_date DESC, accounts.name ASC'] if @q.sorts.empty?

    respond_to do |format|
      format.html {
          @accountinvoices = @q.result.page(params[:page])
      }
      # format.xlsx {
      #   response.headers['Content-Disposition'] = 'attachment; filename=' + "#{I18n.t(:events)}-#{Date.today}.xlsx"
      # }
      # format.csv do
      #   send_data(@accountinvoices.csv_list.encode("UTF-8"), :type => 'text/csv; charset=iso8859-1; header=present', filename: "#{I18n.t(:events)}-#{Date.today}.csv")
      # end
      format.zip {
        @accountinvoices = @q.result
        @pdf_files = AccountinvoicesGetPdfCollection.new(@accountinvoices).perform
        @zipfile = ZipCreateFromCollection.new(@pdf_files).perform

        send_data(@zipfile, :type => 'application/zip', filename: "accountinvoices_#{Date.today}.zip")
      }

    end

  end

  # GET /accountinvoices/1/pdf
  # Generate and show pdf
  def pdf
    # if there is no filename (invoice has not been generated) or the file is not present -> create it
    if @accountinvoice.pdf_file_name.blank? || !@accountinvoice.pdf.exists?
      @accountinvoice.create_pdf
      @accountinvoice.save!
    end
    # new_status = 'printed'
    # if @accountinvoice.accountinvoicestatus.key == 'sent'
    #   new_key = 'printed_and_sent'
    # end
    # @accountinvoice.accountinvoicestatus = Invoicestatus.find_by(key: new_status)
    # @accountinvoice.save!
    # raise @accountinvoice.pdf.url
    send_file(@accountinvoice.pdf.path, filename: @accountinvoice.pdf_file_name, type: 'application/pdf', disposition: 'inline')
  end

  def download
    if @accountinvoice.pdf_file_name.blank?
      @accountinvoice.create_pdf
      @accountinvoice.save!
    end
    # new_status = 'printed'
    # if @accountinvoice.accountinvoicestatus.key == 'sent'
    #   new_key = 'printed_and_sent'
    # end
    # @accountinvoice.accountinvoicestatus = Invoicestatus.find_by(key: new_status)
    # @accountinvoice.save!
    # raise @accountinvoice.pdf.url
    send_file(@accountinvoice.pdf.path, filename: @accountinvoice.pdf_file_name, type: 'application/pdf', disposition: "attachment; filename=#{@accountinvoice.pdf_file_name}")
  end
  # send accountinvoice to customer
  def sendaccountinvoice
    if @accountinvoice.pdf_file_name.blank?
      @accountinvoice.create_pdf
      @accountinvoice.save!
    end
    AccountinvoiceMailer.send_invoice(@accountinvoice).deliver_later
    redirect_to billing_path
  end

  # GET /accountinvoices/1
  def show; end

  # GET /accountinvoices/new
  def new
    @accountinvoice = Accountinvoice.new
  end

  # GET /accountinvoices/createnew
  def createnew
    @accountinvoice.create_pdf
    @accountinvoice.save!
    # @billing_period = BillingPeriod.find(params[:id])
    #
    # @accountinvoice = Accountinvoice.new
    #
    # Accountinvoice.new.create_new(@billing_period, 'invoice', 'new')
    redirect_to admin_accountinvoices_path
  end

  # GET /accountinvoices/cancel
  def cancel
    @accountinvoice = Accountinvoice.find(params[:id])
    accountinvoice_new = Accountinvoice.new

    accountinvoice_new.cancel(@accountinvoice)
    redirect_to billing_path
  end

  # GET /accountinvoices/1/edit
  def edit; end

  # POST /accountinvoices
  def create
    @accountinvoice = Accountinvoice.new(accountinvoice_params)

    if @accountinvoice.save
      redirect_to admin_accountinvoice_path(@accountinvoice), notice: t(:creation_successful)
      redirect_to admin_account_path(@account) + '#billing_periods', notice: t(:delete_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /accountinvoices/1
  def update
    if @accountinvoice.update(accountinvoice_params)
      redirect_to admin_accountinvoice_path(@accountinvoice), notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /accountinvoices/1
  def destroy
    @account = @accountinvoice.account
    @accountinvoice.destroy
    if params[:return] == 'account'
      ret_path = admin_account_path(@account) + '#accountinvoices'
    else
      ret_path = admin_accountinvoices_path
    end
    redirect_to ret_path, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accountinvoice
    @accountinvoice = Accountinvoice.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def accountinvoice_params
    params.require(:accountinvoice).permit(
      :account_id, :booking_id, :invoice_date, :email_to, :invoice_number,
      :payment_date, :recipient_name_1, :recipient_name_2, :street, :street_no,
      :zip, :city, :country, :invoicetype_id, :invoicestatus_id, :successor,
      :predecessor, :pdf_file_name, :pdf_content_type, :pdf_file_size,
      :pdf_updated_at
    )
  end
end
