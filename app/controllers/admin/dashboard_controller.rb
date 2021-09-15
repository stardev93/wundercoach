class Admin::DashboardController < Admin::AdminController
  before_action :set_account, only: %i(accountdetails)

  authorize_resource :account

  def index
    # if search_params[:clear]
    #   #   session[:backend_dashboard_filter] = nil
    #   @from_date = (Date.today - 1.month)
    #   @to_date = Date.today
    # end

    if search_params['from_date'] && search_params['to_date']
      # session[:backend_dashboard_filter] = search_params
      @from_date = search_params['from_date']
      @to_date = search_params['to_date']
    else
      # session[:backend_dashboard_filter] = search_params
      @from_date = (Date.today - 1.month)
      @to_date = Date.today
    end

    @filter = search_params[:filter] if search_params[:filter]
    @key_metrics = Admin::KeyMetricsFacade.new(@from_date, @to_date)

    @accounts = Account.page(params[:page]).order('created_at DESC')
    if params[:search]
      @accounts = @accounts.where("name LIKE :pattern
                                  or email LIKE :pattern
                                  or zip LIKE :pattern",
                                  pattern: "%#{params[:search]}%")
    end
  end

  private

  def search_params
    params.require(:backend).permit(:filter, :clear, :from_date, :to_date)
  end
end
