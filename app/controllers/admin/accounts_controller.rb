class Admin::AccountsController < Admin::AdminController
  before_action :set_account, only: %i(show edit update destroy login_as)

  # GET /admin/accounts
  def index
    if params[:clearsearch] == 'true'
      session.delete('admin_accounts_search')
    end

    session[:admin_accounts_search] = params[:admin_accounts_search] if params[:admin_accounts_search]

    @q = Account.ransack(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @accounts = @q.result.page(params[:page]).includes(:bookings, :users)
    @accounts = @accounts.where('
        name LIKE ?
        OR zip LIKE ?
        OR city LIKE ?
        OR firstname LIKE ?
        OR lastname LIKE ?
        OR email LIKE ?
        OR subdomain LIKE ?',
        "%#{session[:admin_accounts_search]}%",
        "%#{session[:admin_accounts_search]}%",
        "%#{session[:admin_accounts_search]}%",
        "%#{session[:admin_accounts_search]}%",
        "%#{session[:admin_accounts_search]}%",
        "%#{session[:admin_accounts_search]}%",
        "%#{session[:admin_accounts_search]}%") if session[:admin_accounts_search]
  end

  # GET /admin/accounts/1
  def show
    # @eventbookings = @account.eventbookings.page(params[:eventbookingspage])
    # @events = @account.events.page(params[:eventspage])
    @users = @account.users.joins(:roles).where(:roles => {name: "user"}).by_name.page(params[:userspage])
    @accountinvoices = @account.accountinvoices.order('invoice_date DESC').page(params[:accountinvoicespage])
    @payment_adapters = @account.payment_adapters.page(params[:paymentadapterspage])
    @bookings = @account.bookings.order('valid_from DESC').page(params[:bookingspage])
    @billing_periods = @account.billing_periods.order('start_date DESC').page(params[:billing_periods_page])


  end

  def login_as
    logout
    user = @account.users.reorder(id: :asc).first
    auto_login(user)
    redirect_to root_url, notice: "You are now logged in as #{user}"
  end

  # GET /admin/accounts/1/edit
  def edit; end

  # PATCH/PUT /admin/accounts/1
  def update
    if @account.update(account_params)
      redirect_to admin_account_path(@account), notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/accounts/1
  def destroy
    account = @account
    @account.delete
    redirect_to admin_accounts_url, notice: t(:account_marked_as_deleted, :account => account)
  end

  # DELETE /admin/accounts/1
  def deactivate
    @account.deactivate
    redirect_to admin_accounts_url, notice: t(:account.deactivated)
  end

  def compute
    Account.all.each do |account|
      account.last_activity_at = account.users.reorder('last_activity_at DESC').where('last_activity_at IS NOT NULL').first&.last_activity_at
      account.save
    end
    redirect_to admin_accounts_url, notice: t(:compute_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(
      :name, :name_addon, :comments, :zip, :city, :street, :streetno, :country,
      :gender, :firstname, :lastname, :tel1, :tel2, :fax, :email, :homepage,
      :logo, :email_billing, :email_billing_address, :paymentplan_id,
      :accountstatus_id, :accountnumber, :vat_number, :invoice_no_start
    )
  end
end
