class EventpaymentmethodsController < ApplicationController
  before_action :set_eventpaymentmethod, only: %i(show edit update destroy)
  authorize_resource

  # GET /eventpaymentmethods
  def index
    @eventpaymentmethods = Eventpaymentmethod.page(params[:page]).order('name ASC')
    @eventpaymentmethods = @eventpaymentmethods.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /eventpaymentmethods/1
  def show; end

  # GET /eventpaymentmethods/new
  def new
    @eventpaymentmethod = Eventpaymentmethod.new
  end

  # GET /eventpaymentmethods/1/edit
  def edit; end

  # POST /eventpaymentmethods
  def create
    @eventpaymentmethod = Eventpaymentmethod.new(eventpaymentmethod_params)

    if @eventpaymentmethod.save
      redirect_to @eventpaymentmethod, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /eventpaymentmethods/1
  def update
    if @eventpaymentmethod.update(eventpaymentmethod_params)
      redirect_to @eventpaymentmethod, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /eventpaymentmethods/1
  def destroy
    @eventpaymentmethod.destroy
    redirect_to eventpaymentmethods_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_eventpaymentmethod
    @eventpaymentmethod = Eventpaymentmethod.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def eventpaymentmethod_params
    params.require(:eventpaymentmethod).permit(:event_id, :paymentmethod_id)
  end
end
