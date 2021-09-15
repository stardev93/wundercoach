class RequestsController < ApplicationController
  skip_before_action :require_login, only: :create
  skip_before_action :verify_authenticity_token, only: :create
  before_action :set_request, only: %i(show edit update destroy)
  authorize_resource

  # GET /requests
  def index
    @requests = Request.page(params[:page])
    if params[:search]
      @requests = @requests.where(
        "firstname LIKE :pattern
        OR lastname LIKE :pattern",
        pattern: "%#{params[:search]}%"
      )
    end
  end

  # GET /requests/1
  def show; end

  # GET /requests/new
  def new
    @request = Request.new
  end

  # GET /requests/1/edit
  def edit; end

  # POST /requests
  def create
    if params[:request][:free].present? # Free is only used by spam bots
      redirect_to signup_index_path
      return nil
    end
    @request = Request.new(request_params)
    if @request.save
      EventHandler.instance.process(:request_sent, @request)
      redirect_to signup_show_event_path(@request.event), notice: I18n.t(:you_sent_a_request)
    else
      render 'signup/requests/new', layout: 'signup'
    end
  end

  # PATCH/PUT /requests/1
  def update
    if @request.update(request_params)
      redirect_to @request, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /requests/1
  def destroy
    event = @request.event
    @request.destroy
    redirect_to "#{event_path(event)}#requests", notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def request_params
    params.require(:request).permit(:lastname, :firstname, :gender, :tel, :email, :message, :event_id)
  end
end
