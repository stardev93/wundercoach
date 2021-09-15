class AccountinvoicestatusesController < ApplicationController
  before_action :set_accountinvoicestatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /accountinvoicestatuses
  def index
    @accountinvoicestatuses = Accountinvoicestatus.with_translations(I18n.locale).page(params[:page]).order('position ASC')
    @accountinvoicestatuses = @accountinvoicestatuses.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
  end

  # GET /accountinvoicestatuses/1
  def show; end

  # GET /accountinvoicestatuses/new
  def new
    @accountinvoicestatus = Accountinvoicestatus.new
  end

  # GET /accountinvoicestatuses/1/edit
  def edit; end

  # POST /accountinvoicestatuses
  def create
    @accountinvoicestatus = Accountinvoicestatus.new(accountinvoicestatus_params)

    if @accountinvoicestatus.save
      redirect_to accountinvoicestatuses_url, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /accountinvoicestatuses/1
  def update
    if @accountinvoicestatus.update(accountinvoicestatus_params)
      redirect_to accountinvoicestatuses_url, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /accountinvoicestatuses/1
  def destroy
    @accountinvoicestatus.destroy
    redirect_to accountinvoicestatuses_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accountinvoicestatus
    @accountinvoicestatus = Accountinvoicestatus.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def accountinvoicestatus_params
    params.require(:accountinvoicestatus).permit(:key, :name, :description, :position)
  end
end
