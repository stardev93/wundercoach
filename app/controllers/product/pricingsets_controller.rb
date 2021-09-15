class Product::PricingsetsController < ApplicationController
  before_action :set_product_pricingset, only: %i(show edit update destroy assign)

  # GET /product/pricingsets
  def index
    # @product_pricingsets = Product::Pricingset.all
    # @product_pricingsets = pricingset.page(params[:page]).order('id ASC')

    @pricingsets = if params[:search]
      Product::Pricingset.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      Product::Pricingset.page(params[:page]).order('name ASC')
    end
  end

  # GET /product/pricingsets/1
  def show
  end

  # GET /product/pricingsets/new
  def new
    @product_pricingset = Product::Pricingset.new
  end

  # GET /product/pricingsets/1/edit
  def edit
  end

  # POST /product/pricingsets
  def create
    @product_pricingset = Product::Pricingset.new(product_pricingset_params)
    if @product_pricingset.save
      redirect_to @product_pricingset, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /product/pricingsets/1
  def update
    if @product_pricingset.update(product_pricingset_params)
      redirect_to @product_pricingset, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /product/pricingsets/1
  def destroy
    @product_pricingset.destroy
    redirect_to product_pricingsets_url, notice: t(:delete_successful)
  end

  private

  def set_product_pricingset
    @product_pricingset = Product::Pricingset.find(params[:id])
  end

  def product_pricingset_params
    params.require(:product_pricingset).permit(:account_id, :name, :description, :hint_text, :active)
  end
end
