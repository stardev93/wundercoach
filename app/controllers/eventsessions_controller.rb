class EventsessionsController < ApplicationController
  before_action :set_eventsession, only: [:show, :edit, :update, :destroy, :maketoken]
  authorize_resource

  require 'securerandom'
  SecureRandom.uuid

  def calendarlist
    @event = Event.find(params[:event_id])
    @eventsessions = Eventsession.all
  end

  # GET /eventsessions
  def index
    #@eventsessions = Eventsession.all
    #@eventsessions = Eventsession.page(params[:page]).order('id ASC')

    if params[:search]
      @eventsessions = Eventsession.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      @eventsessions = Eventsession.page(params[:page]).order('name ASC')
    end
  end

  # GET /eventsessions/1
  def show
    @asset = Asset.new
    @asset.eventsession = @eventsession
  end

  # GET /eventsessions/1
  def maketoken
    @eventsession.generate_sessioncode
    @eventsession.save
    redirect_to @eventsession.event, notice: t(:creation_successful)
  end

  # GET /eventsessions/new
  def new
    @event = Event.find(params[:event])
    @start_date = @event.getnextstartdate
    @eventsession = Eventsession.new
    @eventsession.event = @event
    #@eventsession.position = @event.getnextnumber
    if !@eventsession.belongs_to_template?
      @eventsession.start_date = @start_date
      @eventsession.end_date = @start_date
    end
    #@eventsession.duration = 1
    @eventsession.durationunit = Durationunit.find_by(key: 'd')
    @eventsession.name = Durationunit.find_by(key: 'd').name_singular

  end

  # GET /eventsessions/1/edit
  def edit
  end

  # POST /eventsessions
  def create
    @eventsession = Eventsession.new(eventsession_params)
    @event = @eventsession.event
    if @eventsession.save
      redirect_to @event, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /eventsessions/1
  def update
    if @eventsession.update(eventsession_params)
      @event = @eventsession.event
      redirect_to @event, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /eventsessions/1
  def destroy
    @event = @eventsession.event
    @eventsession.destroy
    redirect_to @event, notice: t(delete_successful)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_eventsession
      @eventsession = Eventsession.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def eventsession_params
      params.require(:eventsession).permit(:name, :comments, :start_date, :end_date, :durationunit_id, :event_id, :position)
    end
end
