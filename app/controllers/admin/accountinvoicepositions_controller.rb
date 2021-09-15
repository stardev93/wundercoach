class AccountinvoicepositionsController < ApplicationController
  before_action :set_accountinvoiceposition, only: %i(show edit update destroy)
  authorize_resource

  # GET /Accountinvoicepositions
  def index
    @accountinvoicepositions = Accountinvoiceposition.page(params[:page]).order('name ASC')
    @accountinvoicepositions = @accountinvoicepositions.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
  end

  # GET /Accountinvoicepositions/1
  def show; end

  # GET /Accountinvoicepositions/new
  def new
    @accountinvoiceposition = Accountinvoiceposition.new
  end

  # GET /Accountinvoicepositions/1/edit
  def edit; end

  # POST /Accountinvoicepositions
  def create
    @accountinvoiceposition = Accountinvoiceposition.new(accountinvoiceposition_params)
    if @accountinvoiceposition.save
      redirect_to @accountinvoiceposition, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /Accountinvoicepositions/1
  def update
    if @accountinvoiceposition.update(accountinvoiceposition_params)
      redirect_to @accountinvoiceposition, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /Accountinvoicepositions/1
  def destroy
    @accountinvoiceposition.destroy
    redirect_to Accountinvoicepositions_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accountinvoiceposition
    @accountinvoiceposition = Accountinvoiceposition.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def accountinvoiceposition_params
    params.require(:accountinvoiceposition).permit(:accountinvoice_id, :position, :paymentplan_id, :paymentplan_name, :paymentplan_cycle, :paymentplan_amount, :paymentplan_price)
  end
end
