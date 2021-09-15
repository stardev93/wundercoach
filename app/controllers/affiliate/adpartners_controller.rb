class Affiliate < ActiveRecord::Base
  # crud operations for an affiliate's adpartners
  class AdpartnersController < BaseController
    before_action :set_adpartner, only: %i(show edit update destroy)
    before_action :set_filters, only: %i(index show)

    # GET /adpartners
    def index
      @adpartners = @affiliate.adpartners.page(params[:page]).order('name ASC')
      @adpartners = @adpartners.where('name LIKE %?%', params[:search]) if params[:search]
      @sales = @affiliate.orders.filter(@filters).group(:adpartner_id).reorder('sum_orders_price_cents DESC').sum('orders.price_cents')
    end

    # GET /adpartners/1
    def show
      @orders = @adpartner.orders.reorder(:account_id).filter(@filters).includes(:product, :account)

      orders = @adpartner.orders.filter(@filters)
      @sum = {
        price: orders.sum('orders.price_cents'),
        account_commission: orders.reduce(0) {|sum, order| sum + order.affiliate_commission },
        adpartner_commission: orders.reduce(0) {|sum, order| sum + order.adpartner_commission },
        affiliate_commission: orders.reduce(0) {|sum, order| sum + order.net_affiliate_commission }
      }
    end

    # GET /adpartners/new
    def new
      @adpartner = Adpartner.new
    end

    # GET /adpartners/1/edit
    def edit; end

    # POST /adpartners
    def create
      @adpartner = Adpartner.new(adpartner_params)
      @adpartner.affiliate = @affiliate
      if @adpartner.save
        redirect_to affiliate_adpartner_path(@adpartner), notice: t(:creation_successful)
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /adpartners/1
    def update
      if @adpartner.update(adpartner_params)
        redirect_to affiliate_adpartner_path(@adpartner), notice: t(:update_successful)
      else
        render action: 'edit'
      end
    end

    # DELETE /adpartners/1
    def destroy
      @adpartner.destroy
      redirect_to affiliate_adpartners_url, notice: t(:delete_successful)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_adpartner
      @adpartner = Adpartner.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def adpartner_params
      params.require(:adpartner).permit(
        :name, :name_addon, :lastname, :firstname, :street, :zip, :city,
        :country, :email, :website, :commission_absolute, :commission_relative
      )
    end

    def search_params
      params.require(:affiliate_adpartner_sales).permit(:search, :start_date, :end_date)
    end

    def set_filters
      if params[:clear]
        session[:affiliate_adpartner_sales_filter] = nil
      elsif params[:affiliate_adpartner_sales]
        session[:affiliate_adpartner_sales_filter] = search_params
      end
      @filters = session[:affiliate_adpartner_sales_filter] || {}
    end
  end
end
