class EventbookingstatusesController < ApplicationController
  before_action :set_eventbookingstatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /eventbookingstatuses
  def index
    @eventbookingstatuses = Eventbookingstatus.with_translations(I18n.locale).page(params[:page]).order('name ASC')
    @eventbookingstatuses = @eventbookingstatuses.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /eventbookingstatuses/1
  def show; end

  # GET /eventbookingstatuses/new
  def new
    @eventbookingstatus = Eventbookingstatus.new
  end

  # GET /eventbookingstatuses/1/edit
  def edit; end

  # POST /eventbookingstatuses
  def create
    @eventbookingstatus = Eventbookingstatus.new(eventbookingstatus_params)
    if @eventbookingstatus.save
      redirect_to eventbookingstatuses_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /eventbookingstatuses/1
  def update
    if @eventbookingstatus.update(eventbookingstatus_params)
      redirect_to eventbookingstatuses_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /eventbookingstatuses/1
  def destroy
    @eventbookingstatus.destroy
    redirect_to eventbookingstatuses_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_eventbookingstatus
    @eventbookingstatus = Eventbookingstatus.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def eventbookingstatus_params
    params.require(:eventbookingstatus).permit(:key, :name, :description, :css_class, :position, :icon, :color)
  end
end
