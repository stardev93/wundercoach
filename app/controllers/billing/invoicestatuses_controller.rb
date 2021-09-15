class InvoicestatusesController < ApplicationController
  before_action :set_invoicestatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /invoicestatuses
  def index
    # @invoicestatuses = Invoicestatus.all
    # @invoicestatuses = Invoicestatus.page(params[:page]).order('id ASC')

    @invoicestatuses = if params[:search]
                         Invoicestatus.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
                       else
                         Invoicestatus.page(params[:page]).order('name ASC')
    end
  end

  # GET /invoicestatuses/1
  def show; end

  # GET /invoicestatuses/new
  def new
    @invoicestatus = Invoicestatus.new
  end

  # GET /invoicestatuses/1/edit
  def edit; end

  # POST /invoicestatuses
  def create
    @invoicestatus = Invoicestatus.new(invoicestatus_params)

    if @invoicestatus.save
      redirect_to @invoicestatus, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /invoicestatuses/1
  def update
    if @invoicestatus.update(invoicestatus_params)
      redirect_to @invoicestatus, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /invoicestatuses/1
  def destroy
    @invoicestatus.destroy
    redirect_to invoicestatuses_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invoicestatus
    @invoicestatus = Invoicestatus.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def invoicestatus_params
    params.require(:invoicestatus).permit(:key, :name, :description, :position, :color, :icon)
  end
end
