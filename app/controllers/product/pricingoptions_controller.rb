class Product::PricingoptionsController < ApplicationController
  before_action :set_product_pricingoption, only: %i(show edit update destroy)

  # GET /product/pricingoptions
  def index
    # @product_pricingoptions = Product::Pricingoption.all
    # @product_pricingoptions = Pricingoption.page(params[:page]).order('id ASC')
    @pricingoptions = if params[:search]
      Product::Pricingoption.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      Product::Pricingoption.page(params[:page]).order('name ASC')
    end
  end

  # GET /product/pricingoptions/1
  def show
  end

  # GET /product/pricingoptions/new
  def new
    @product_pricingoption = Product::Pricingoption.new
  end

  # GET /product/pricingoptions/1/edit
  def edit
  end

  # POST /product/pricingoptions
  def create
    @product_pricingoption = Product::Pricingoption.new(product_pricingoption_params)
    if @product_pricingoption.save
      redirect_to @product_pricingoption.pricingset, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /product/pricingoptions/1
  def update
    if @product_pricingoption.update(product_pricingoption_params)
      redirect_to @product_pricingoption.pricingset, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /product/pricingoptions/1
  def destroy
    @product_pricingset = @product_pricingoption.pricingset
    @product_pricingoption.destroy
    # redirect_to product_pricingoptions_url, notice: t(:)
    redirect_to @product_pricingset, notice: t(:delete_successful)
  end

  def sort
    params[:product_pricingoption].each_with_index do |id, index|
      Product::Pricingoption.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

  private

  def set_product_pricingoption
    @product_pricingoption = Product::Pricingoption.find(params[:id])
  end

  def product_pricingoption_params
    params.require(:product_pricingoption).permit(:account_id, :pricingset_id, :name, :comments, :hint_text, :full_price_deduct, :price_early_signup_deduct, :full_price_deduct_perc, :price_early_signup_deduct_perc, :position, :preset)
  end
end
