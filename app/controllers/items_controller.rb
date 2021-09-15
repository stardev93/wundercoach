class ItemsController < ApplicationController
  before_action :set_item, only: %i(show edit update destroy)

  # GET /items
  def index
    # @items = Item.all
    # @items = Item.page(params[:page]).order('id ASC')
    @items = if params[:search]
      Item.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      Item.page(params[:page]).order('name ASC')
    end
  end

  # GET /items/1
  def show
    @item = @item.decorate
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to @item, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /items/1
  def update
    if @item.update(item_params)
      redirect_to @item, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy
    redirect_to items_url, notice: t(:delete_successful)
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:account_id, :name, :shortdescription, :longdescription, :unit, :vat_id, :price, :currency)
  end
end
