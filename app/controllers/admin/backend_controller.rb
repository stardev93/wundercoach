class Admin::BackendController < Admin::AdminController
  def index
    @accounts = Account.page(params[:page]).order('created_at DESC')
    if params[:search]
      @accounts = @accounts.where("name LIKE :pattern
                                      or email LIKE :pattern
                                      or zip LIKE :pattern",
                                  pattern: "%#{params[:search]}%")
    end
  end

  def bookings
    @bookings = Booking.page(params[:page]).order('created_at DESC')
    @bookings = @bookings.all
    # where("name LIKE :pattern
    # or email LIKE :pattern
    # or zip LIKE :pattern",
    # pattern: "%#{params[:search]}%") if params[:search]
  end

  def invoices
    @invoices = Invoice.page(params[:page]).order('created_at DESC')
    @invoices = @invoices.all
    # where("name LIKE :pattern
    # or email LIKE :pattern
    # or zip LIKE :pattern",
    # pattern: "%#{params[:search]}%") if params[:search]
  end

  def accountdetails; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  def search_params
    params.require(:backend).permit(:filter, :clear, :from_date, :to_date)
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(
      :name, :name_addon, :comments, :zip,
      :city, :street, :streetno, :country, :gender, :firstname, :lastname,
      :tel1, :tel2, :fax, :email, :homepage, :logo, :payment_adapter_id,
      :email_billing_address, :accountstatus_id, :terms_link,
      :vat_number, :invoice_no_start, :subdomain, :token, :show_header_image,
      :eventheader, :css_code, :js_code, :invoice_from_small,
      :invoice_from, :invoice_footer, :tax_id, :invoicelogo, :domain, :active,
      :event_contact, :vat_included, :terms_link_text, :terms_required,
      :tracking_code, :robots_txt, :landingpagecode, :websiteintegration_done
    )
  end
end
