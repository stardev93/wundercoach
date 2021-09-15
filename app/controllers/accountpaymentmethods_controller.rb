class AccountpaymentmethodsController < ApplicationController
  before_action :set_accountpaymentmethod, only: %i(show edit update destroy deactivate)
  authorize_resource

  # GET /accountpaymentmethods
  def index
    @accountpaymentmethods = if params[:search]
                               Accountpaymentmethod.where("key LIKE ?", "%#{params[:search]}%").page(params[:page])
                             else
                               Accountpaymentmethod.page(params[:page])
    end
  end

  # GET /accountpaymentmethods/1
  def show; end

  # GET /accountpaymentmethods/new
  def new
    @accountpaymentmethod = Accountpaymentmethod.new
  end

  # GET /accountpaymentmethods/1/edit
  def edit; end

  # POST /accountpaymentmethods
  def create
    @accountpaymentmethod = Accountpaymentmethod.new(accountpaymentmethod_params)
    if @accountpaymentmethod.save
      redirect_to payment_path, notice: t(:accountpaymentmethod_successfully_created)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /accountpaymentmethods/1
  def update
    if @accountpaymentmethod.update(accountpaymentmethod_params)
      redirect_to payment_path, notice: t(:accountpaymentmethod_successfully_updated)
    else
      render action: 'edit'
    end
  end

  # DELETE /accountpaymentmethods/1
  def destroy
    @accountpaymentmethod.destroy
    redirect_to accountpaymentmethods_url, notice: t(:accountpaymentmethod_successfully_deleted)
  end

  # GET /accountpaymentmethods/1/assign/role_id
  def activate
    accountpaymentmethod = Accountpaymentmethod.find_or_initialize_by(paymentmethod_id: params[:id])
    accountpaymentmethod.activate
    accountpaymentmethod.save!
    redirect_to payment_path, notice: t(:paymentmethod_successfully_activated)
  end

  # GET /users/1/revokerole
  def deactivate
    @accountpaymentmethod.deactivate
    redirect_to payment_path, notice: t(:paymentmethod_successfully_deactivated)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accountpaymentmethod
    @accountpaymentmethod = Accountpaymentmethod.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def accountpaymentmethod_params
    params.require(:accountpaymentmethod).permit(:paymentmethod_id, :is_active)
  end
end
