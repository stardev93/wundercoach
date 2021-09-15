class PaymentstatusesController < ApplicationController
  before_action :set_paymentstatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /paymentstatuses
  def index
    @paymentstatuses = if params[:search]
                         Paymentstatus.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
                       else
                         Paymentstatus.page(params[:page]).order('name ASC')
    end
  end

  # GET /paymentstatuses/1
  def show; end

  # GET /paymentstatuses/new
  def new
    @paymentstatus = Paymentstatus.new
  end

  # GET /paymentstatuses/1/edit
  def edit; end

  # POST /paymentstatuses
  def create
    @paymentstatus = Paymentstatus.new(paymentstatus_params)

    if @paymentstatus.save
      redirect_to @paymentstatus, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /paymentstatuses/1
  def update
    if @paymentstatus.update(paymentstatus_params)
      redirect_to @paymentstatus, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /paymentstatuses/1
  def destroy
    @paymentstatus.destroy
    redirect_to paymentstatuses_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_paymentstatus
    @paymentstatus = Paymentstatus.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def paymentstatus_params
    params.require(:paymentstatus).permit(:key, :name, :comment)
  end
end
