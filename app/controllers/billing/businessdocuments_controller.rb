class Billing::BusinessdocumentsController < ApplicationController
  before_action :set_businessdocument, only: %i(show edit update destroy cancel set_paid create_pdf send_to_customer duplicate download createcontact assigncontact)
  after_action  :freeze_invoice, only: %i(pdf send_to_customer)
  before_action :set_filters, only: :index
  authorize_resource

  # GET /invoices
  def index
    #ToDo: make recipient / address filterable
    @businessdocuments = Billing::Businessdocument.filter(@filters).includes(:businessdocumentpositions, :paymentstatus, order: :paymentmethod).page(params[:page])
    @invoicetypes = Billing::Invoicetype.joins(:translations).with_translations(I18n.locale).pluck(:name, :id)
    @paymentmethods = @account.paymentmethods.joins(:translations).with_translations(I18n.locale).pluck(:name, :id)
    @paymentstatuses = Paymentstatus.joins(:translations).with_translations(I18n.locale).pluck(:name, :id)
    respond_to do |format|
      format.html { @businessdocuments }
      format.xlsx {
        authorize_feature! 'csv_export'
        response.headers['Content-Disposition'] = 'attachment; filename=' + "#{I18n.t(:invoicelist)}-#{Date.today}.xlsx"
      }
      format.csv do
        authorize_feature! 'csv_export'
        send_data(@eventbookings.csv_invoices.encode("ISO-8859-1"), :type => 'text/csv; charset=iso8859-1; header=present', filename: "#{I18n.t(:invoicelist)}-#{Date.today}.csv")
      end
      format.pdf do
        authorize_feature! 'printable_views'
        send_data(Billing::Invoice.invoicelist_pdf(@businessdocuments), filename: "#{I18n.t(:invoicelist)}.pdf", type: 'application/pdf', disposition: 'inline')
      end
    end
  end

  # GET /invoices/1
  def show
    @businessdocument = @businessdocument.decorate
    # create businessdocumentposition from event
    if params[:event]
      @event = Event.find(params[:event])
      InvoicepositionCreateFromEvent.new(@businessdocument, @event).perform
      redirect_to billing_businessdocument_path(@businessdocument), notice: t(:cancel_message)
    end
    # create businessdocumentposition from bundle
    if params[:bundle]
      @bundle = BundleEvent.find(params[:bundle])
      InvoicepositionCreateFromBundle.new(@businessdocument, @bundle).perform
      redirect_to billing_businessdocument_path(@businessdocument), notice: t(:cancel_message)
    end
    # create businessdocumentposition from item
    if params[:item]
      @item = Item.find(params[:item])
      InvoicepositionCreateFromItem.new(@businessdocument, @item).perform
      redirect_to billing_businessdocument_path(@businessdocument), notice: t(:cancel_message)
    end
  end

  # GET /changestatus/1/status
  def cancel
    @cancellation = @businessdocument.cancel
    redirect_to billing_businessdocument_path(@cancellation), notice: t(:cancel_message)
  end

  # POST /businessdocuments/1/set_paid
  def set_paid
    @businessdocument.change_paymentstatus(Paymentstatus.find(params[:paid]))
    notice = if @businessdocument.save
               case @businessdocument.paymentstatus.key
               when 'open'
                 t(:paymentstatus_set_to_open)
                 @businessdocument.paymentdate = ''
                 @businessdocument.save
               when 'paid'
                 t(:paymentstatus_set_to_paid)
               when 'waiting'
                 t(:paymentstatus_set_to_waiting)
               end
             else
               t(:could_not_set_paymentstatus)
    end
    redirect_to billing_businessdocument_path(@businessdocument), notice: notice
  end

  # GET /invoices/1/send_to_customer
  # sends an invoice to customer manually
  def send_to_customer
    # call service businessdocument.document_send and delay it for background processing
    @businessdocument.document_send
    redirect_to billing_businessdocument_path(@businessdocument), notice: t(:businessdocument_has_been_sent)
  end

  # GET /invoices/1/pdf
  # Generate pdf
  def create_pdf
    @new_businessdocument = @businessdocument.create_pdf
    redirect_to billing_businessdocument_path(@new_businessdocument), notice: t(:pdf_generation_started)
  end

  # GET /invoices/1/download
  # open pdf in browser
  def download
    @businessdocument.create_pdf
    if !@businessdocument.pdf_exists?
      # @businessdocument.create_pdf
    end
    send_file(@businessdocument.pdf.path, filename: @businessdocument.pdf_file_name, type: 'application/pdf', disposition: 'inline')
  end

  # GET /invoices/new
  def new
    @businessdocument = Billing::Invoice.new
  end

  # GET /invoices/1/edit
  def edit; end

  # POST /invoices
  def create
    @businessdocument = Billing::Invoice.new(businessdocument_params)
    if @businessdocument.save
      redirect_to billing_businessdocument_path(@businessdocument), notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /businessdocuments/1
  def update
    if @businessdocument.update(businessdocument_params)
      redirect_to billing_businessdocument_path(@businessdocument), notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /businessdocuments/1
  def destroy
    #@businessdocument.destroy!
    BusinessdocumentDelete.new(@businessdocument).perform
    redirect_to billing_businessdocuments_path, notice: t(:delete_successful)
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to billing_businessdocument_path(@businessdocument), alert: e.message
  end

  # duplicate a businessdocument
  def duplicate
    @businessdocument.duplicate
    redirect_to billing_businessdocument_path(@businessdocument), notice: t(:document_duplicated)
  end

  # duplicate a businessdocumentposition
  def duplicateposition
    @businessdocumentposition = Billing::Businessdocumentposition.find(params[:id])
    @businessdocumentposition.duplicate
    redirect_to billing_businessdocument_path(@businessdocumentposition.businessdocument), notice: t(:position_duplicated)
  end

  # DELETE /businessdocuments/1
  def deleteposition
    @businessdocumentposition = Billing::Businessdocumentposition.find(params[:id])
    @businessdocument = @businessdocumentposition.businessdocument
    @businessdocumentposition.destroy!
    redirect_to billing_businessdocument_path(@businessdocument), notice: t(:delete_successful)
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to billing_businessdocument_path(@businessdocument), alert: e.message
  end

  def new_invoice

    @contact_address = Crm::ContactAddress.find(params[:contact_address_id])
    @businessdocument = InvoiceCreate.new(@contact_address).perform

    redirect_to billing_businessdocument_path(@businessdocument), notice: t(:invoice_creation_successful)
  end

  def new_quote

    @contact_address = Crm::ContactAddress.find(params[:contact_address_id])
    @businessdocument = QuoteCreate.new(@contact_address).perform

    redirect_to billing_businessdocument_path(@businessdocument), notice: t(:invoice_creation_successful)
  end

  # GET /datevexport
  def datevexport
    authorize_feature! 'csv_export'
    @account = current_tenant
    date_from = Date.today.beginning_of_year
    if @account.export_fixed_at_start_date.nil?
      @account.export_fixed_at_start_date
    end
  end

  # Package download in views/billing/datevdownload.xlsx.axlsx
  # POST /datevexport
  def datevdownload
    if params[:account][:export_fixed_at_start_date]
      date_from = params[:account][:export_fixed_at_start_date]
    else
      date_from = Date.today.beginning_of_month
    end
    if params[:account][:export_fixed_at_end_date]
      date_to = params[:account][:export_fixed_at_end_date]
    else
      date_to = Date.today.end_of_month
    end
    #@contacts = Billing::Businessdocument.joins(:contact).where("businessdocuments.type='Billing::Invoice' or businessdocuments.type='Billing::Cancellation'")
    @contact_ids = ''
    @businessdocumentpositions = Billing::Businessdocumentposition.includes(:businessdocument, :vat).where("(businessdocuments.type='Billing::Invoice' or businessdocuments.type='Billing::Cancellation') and invoice_number IS NOT NULL and invoice_date >= '#{date_from}' AND invoice_date <= '#{date_to}'").order("businessdocuments.invoice_number, businessdocuments.id, businessdocumentpositions.position, businessdocumentpositions.id")
    @businessdocuments = Billing::Businessdocument.where("(businessdocuments.type='Billing::Invoice' or businessdocuments.type='Billing::Cancellation') and invoice_date >= '#{date_from}' AND invoice_date <= '#{date_to}'").order("businessdocuments.invoice_number, businessdocuments.id")

    @account = current_tenant
    if params[:account][:export_fixed_at_start_date] and params[:account][:export_fixed_at_end_date]
      @account.tax_consultant_id = params[:account][:tax_consultant_id]
      @account.tax_consultant_client_id = params[:account][:tax_consultant_client_id]
      @account.revenue_account = params[:account][:revenue_account]
      @account.export_fixed_at_start_date = params[:account][:export_fixed_at_start_date]
      @account.export_fixed_at_end_date = params[:account][:export_fixed_at_end_date]
      @account.save
    end
    respond_to do |format|
      format.xlsx {
        authorize_feature! 'csv_export'
        response.headers['Content-Disposition'] = 'attachment; filename=' + "EXTF_#{I18n.t(:invoicelist)}-#{Date.today}.xlsx"
      }
      # format.csv {
      #   authorize_feature! 'csv_export'
      #   response.headers['Content-Disposition'] = 'attachment; filename=' + "#{I18n.t(:datevexport_csv_filename, startdate: @account.export_fixed_at_start_date.to_s, enddate: @account.export_fixed_at_end_date.to_s, createdate: Date.today.to_s)}.csv"
      # }
      format.csv do
        require 'zip'

        authorize_feature! 'csv_export'

        # create tmp_file with account id to ensure unique filenames
        tmp_dir = Rails.root.join('tmp', @account.id.to_s)
        Dir.mkdir(tmp_dir) unless File.exists?(tmp_dir)

        tmp_dir = Rails.root.join(tmp_dir, current_user.id.to_s)
        Dir.mkdir(tmp_dir) unless File.exists?(tmp_dir)


        start_date_short = (l @account.export_fixed_at_start_date, format: '%Y%m%d').to_s
        end_date_short = (l @account.export_fixed_at_end_date, format: '%Y%m%d').to_s
        today_short = (l Date.today, format: '%Y%m%d').to_s

        zip_file_name = "DATEV-Export_#{t(:from)}_#{start_date_short}_#{t(:until)}_#{end_date_short}_erstellt_#{today_short}.zip"

        filename_accounts = "EXTF_GP_Stamm_#{(l Date.today, format: '%Y%m%d')}.csv"
        filename_batch = "EXTF_Buchungsstapel_#{(@account.export_fixed_at_start_date.blank? ? '' : (l @account.export_fixed_at_start_date, format: '%Y%m%d').to_s)}_bis_#{(@account.export_fixed_at_end_date.blank? ? '' : (l @account.export_fixed_at_end_date, format: '%Y%m%d').to_s)}.csv"

        zip_file_path = Rails.root.join(tmp_dir, zip_file_name)
        File.delete(zip_file_path) if File.exist?(zip_file_path)

        Zip::ZipFile.open(zip_file_path.to_s, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.get_output_stream(filename_accounts) { |f| f.write BusinessdocumentExportDatevCsv.new.get_contacts(@account, @businessdocumentpositions) }
          zipfile.get_output_stream(filename_batch) { |f| f.write BusinessdocumentExportDatevCsv.new.get_invoicepositions(@account, @businessdocumentpositions, date_from, date_to) }
        end

        send_file(zip_file_path, :type => 'application/zip', :disposition => 'attachment', :filename => zip_file_name)

      end
    end
  end

  # GET /businessdocuments/1/createcontact
  def createcontact
    authorize_feature! 'contact_manager'
    @contact = ContactCreateFromBusinessdocument.new(@businessdocument).perform
    @businessdocument = ContactAddToEventbooking.new(@businessdocument).perform
    if @contact
      notice = t(:contact_created)
    else
      notice = t(:error_creating_contact)
    end
    redirect_to billing_businessdocument_path(@businessdocument), notice: notice
  end

  # GET /businessdocuments/1/createcontact
  def assigncontact
    authorize_feature! 'contact_manager'
    @contact = Crm::Contact.find(params[:contact_id])
    @contact = ContactAssignToBusinessdocument.new(@businessdocument, @contact).perform
    @businessdocument = ContactAddToEventbooking.new(@businessdocument).perform
    if @contact
      notice = t(:contact_created)
    else
      notice = t(:error_creating_contact)
    end
    redirect_to billing_businessdocument_path(@businessdocument), notice: notice
  end

  private

  def set_filters
    if params[:clear]
      session[:invoice_filter] = nil
    elsif params[:invoice]
      session[:invoice_filter] = search_params
    end
    @filters = session[:invoice_filter] || {}
  end

  def freeze_invoice
    @businessdocument.invoicestatus = Billing::Invoicestatus.find_by key: 'sent'
    @businessdocument.save!
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_businessdocument
    # find any invoice.type by using Businessdocument as object class
    # so that search for STI object is NOT used
    @businessdocument = Billing::Businessdocument.find(params[:id])
  end

  def search_params
    params.require(:invoice).permit(:search, :start_date, :end_date, :invoicetype, :paymentstatus, :paymentmethod)
  end

  def businessdocument_params
    # ToDo: dirty, change this later. crm:: namespace works without this.
    key = (params.keys & %w(billing_businessdocument billing_invoice billing_quote billing_cancellation billing_orderconfirmation account))[0]
    params.require(key).permit(
      :name, :comments, :invoice_date, :paymentmethod, :paymentdate,
      :paymentstatus, :paymentstatus_id, :due_date, :invoice_number,
      :invoicetype_id, :invoicestatus_id,
      :successor, :predecessor, :recipient1, :recipient2,
      :contact_id, :contact_address_id, :recipient_name1, :recipient_name2,
      :recipient_person, :recipient_street, :recipient_zip , :recipient_email,
      :recipient_city, :recipient_country, :vat_included, :account_receivable_no,
      :contact_no, :tax_consultant_id, :tax_consultant_client_id, :costcenter,
      :revenue_account, :export_fixed_at_start_date, :export_fixed_at_end_date, address_attributes: Address::FORM_ATTRIBUTES
      #, account_attributes: Account::FORM_ATTRIBUTES
    )
  end
end
