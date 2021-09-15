class EventsessionbookingsController < ApplicationController
  before_action :set_eventsessionbooking, only: [:show, :edit, :update, :destroy]
  authorize_resource

  # GET /eventsessionbookings
  def index
    #@eventsessionbookings = Eventsessionbooking.all
    #@eventsessionbookings = Eventsessionbooking.page(params[:page]).order('id ASC')

    if params[:search]
      @eventsessionbookings = Eventsessionbooking.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      @eventsessionbookings = Eventsessionbooking.page(params[:page]).order('name ASC')
    end
  end

  # GET /eventsessionbookings/1
  def show
  end

  # GET /eventsessionbookings/new
  def new
    @eventsessionbooking = Eventsessionbooking.new
  end

  # GET /eventsessionbookings/1/edit
  def edit
  end

  # POST /eventsessionbookings
  def create
    @eventsessionbooking = Eventsessionbooking.new(eventsessionbooking_params)

    if @eventsessionbooking.save
      redirect_to @eventsessionbooking, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /eventsessionbookings/1
  def update
    if @eventsessionbooking.update(eventsessionbooking_params)
      redirect_to @eventsessionbooking, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /eventsessionbookings/1
  def destroy
    @eventsessionbooking.destroy
    redirect_to eventsessionbookings_url, notice: t(:delete_successful)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_eventsessionbooking
      @eventsessionbooking = Eventsessionbooking.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def eventsessionbooking_params
      params.require(:eventsessionbooking).permit(:event_id, :eventsession_id, :user_id, :eventsessionbookingstatus)
    end
end
