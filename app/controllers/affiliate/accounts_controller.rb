class Affiliate < ActiveRecord::Base
  # offers account login_as function and crud operations to affiliates
  class AccountsController < BaseController
    before_action :set_account, except: :index
    before_action :set_filters, only: %i(index show)
    # log in as account creator
    def login_as
      logout
      user = @account.users.reorder(id: :asc).first
      auto_login(user)
      redirect_to root_url, notice: "You are now logged in as #{user}"
    end

    def show
      @orders = @account.orders.confirmed.reorder(:adpartner_id).filter(@filters)
      @sum = @orders.sum('orders.price_cents')
      @sum = {
        price: @orders.sum('orders.price_cents'),
        account_commission: @orders.reduce(0) {|sum, order| sum + order.affiliate_commission },
        adpartner_commission: @orders.reduce(0) {|sum, order| sum + order.adpartner_commission },
        affiliate_commission: @orders.reduce(0) {|sum, order| sum + order.net_affiliate_commission }
      }
    end

    def edit; end

    def update
      if @account.update(account_params)
        redirect_to affiliate_dashboard_path(anchor: 'accounts'), notice: t(:update_successful)
      else
        render action: 'edit'
      end
    end

    def index
      @accounts = @affiliate.accounts
      # hash account_id => sum
      @sales = @affiliate.orders.filter(@filters).group(:account_id).reorder('sum_orders_price_cents DESC').sum('orders.price_cents')
    end

    private

    def set_account
      @account = @affiliate.accounts.find(params[:id])
    end

    def account_params
      params.require(:account).permit(:affiliate_commission_relative, :affiliate_commission_absolute)
    end

    def search_params
      params.require(:affiliate_account_sales).permit(:search, :start_date, :end_date)
    end

    def set_filters
      if params[:clear]
        session[:affiliate_account_sales_filter] = nil
      elsif params[:affiliate_account_sales]
        session[:affiliate_account_sales_filter] = search_params
      end
      @filters = session[:affiliate_account_sales_filter] || {}
    end
  end
end
