class EventtypesController < ApplicationController
  before_action :set_eventtype, only: %i(show edit update destroy)
  authorize_resource

  # GET /eventtypes
  def index
    @eventtypes = Eventtype.with_translations(I18n.locale).where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
    #@eventtypes = @eventtypes.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /eventtypes/1
  def show; end

  # GET /eventtypes/new
  def new
    @eventtype = Eventtype.new
  end

  # GET /eventtypes/1/edit
  def edit; end

  # POST /eventtypes
  def create
    @eventtype = Eventtype.new(eventtype_params)

    if @eventtype.save
      redirect_to @eventtype, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /eventtypes/1
  def update
    if @eventtype.update(eventtype_params)
      redirect_to @eventtype, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /eventtypes/1
  def destroy
    @eventtype.destroy
    redirect_to eventtypes_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_eventtype
    @eventtype = Eventtype.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def eventtype_params
    params.require(:eventtype).permit(:key, :name, :description, :colorcode)
  end
end
