class InvoicetypesController < ApplicationController
  before_action :set_invoicetype, only: %i(show edit update destroy)
  authorize_resource

  # GET /invoicetypes
  def index
    # @invoicetypes = Invoicetype.all
    # @invoicetypes = Invoicetype.page(params[:page]).order('id ASC')

    @invoicetypes = if params[:search]
                      Invoicetype.with_translations(I18n.locale).where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
                    else
                      Invoicetype.with_translations(I18n.locale).page(params[:page]).order('name ASC')
    end
  end

  # GET /invoicetypes/1
  def show; end

  # GET /invoicetypes/new
  def new
    @invoicetype = Invoicetype.new
  end

  # GET /invoicetypes/1/edit
  def edit; end

  # POST /invoicetypes
  def create
    @invoicetype = Invoicetype.new(invoicetype_params)

    if @invoicetype.save
      redirect_to @invoicetype, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /invoicetypes/1
  def update
    if @invoicetype.update(invoicetype_params)
      redirect_to @invoicetype, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /invoicetypes/1
  def destroy
    @invoicetype.destroy
    redirect_to invoicetypes_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invoicetype
    @invoicetype = Invoicetype.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def invoicetype_params
    params.require(:invoicetype).permit(:key, :name, :description, :position)
  end
end
