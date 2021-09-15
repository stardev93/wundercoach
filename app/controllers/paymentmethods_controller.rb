class PaymentmethodsController < ApplicationController
  before_action :set_paymentmethod, only: %i(show edit update destroy)
  authorize_resource

  # GET /paymentmethods
  def index
    @paymentmethods = if params[:search]
                        Paymentmethod.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
                      else
                        Paymentmethod.page(params[:page]).order('name ASC')
    end
  end

  # GET /paymentmethods/1
  def show; end

  # GET /paymentmethods/new
  def new
    @paymentmethod = Paymentmethod.new
  end

  # GET /paymentmethods/1/edit
  def edit; end

  # POST /paymentmethods
  def create
    @paymentmethod = Paymentmethod.new(paymentmethod_params)
    if @paymentmethod.save
      redirect_to paymentmethods_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /paymentmethods/1
  def update
    if @paymentmethod.update(paymentmethod_params)
      redirect_to paymentmethods_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /paymentmethods/1
  def destroy
    @paymentmethod.destroy
    redirect_to paymentmethods_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_paymentmethod
    @paymentmethod = Paymentmethod.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def paymentmethod_params
    params.require(:paymentmethod).permit(:key, :name, :comment, :image, :thankyou_text)
  end
end
