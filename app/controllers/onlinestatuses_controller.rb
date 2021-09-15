class OnlinestatusesController < ApplicationController
  before_action :set_onlinestatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /onlinestatuses
  def index
    @onlinestatuses = if params[:search]
                        Onlinestatus.with_translations.distinct.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
                      else
                        Onlinestatus.with_translations.distinct.page(params[:page]).order('name ASC')
    end
  end

  # GET /onlinestatuses/1
  def show; end

  # GET /onlinestatuses/new
  def new
    @onlinestatus = Onlinestatus.new
  end

  # GET /onlinestatuses/1/edit
  def edit; end

  # POST /onlinestatuses
  def create
    @onlinestatus = Onlinestatus.new(onlinestatus_params)

    if @onlinestatus.save
      redirect_to onlinestatuses_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /onlinestatuses/1
  def update
    if @onlinestatus.update(onlinestatus_params)
      redirect_to onlinestatuses_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /onlinestatuses/1
  def destroy
    @onlinestatus.destroy
    redirect_to onlinestatuses_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_onlinestatus
    @onlinestatus = Onlinestatus.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def onlinestatus_params
    params.require(:onlinestatus).permit(:key, :name, :description, :position, :icon, :color)
  end
end
