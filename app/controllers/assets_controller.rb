class AssetsController < ApplicationController
  before_action :set_asset, only: %i(show edit update destroy)
  authorize_resource

  # GET /assets
  def index
    @asset = Asset.new
    @assets = Asset.page(params[:page]).order('name ASC')
    @assets = @assets.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /assets/1
  def show; end

  # GET /assets/new
  def new
    @asset = Asset.new
  end

  # GET /assets/1/edit
  def edit; end

  # POST /assets
  def create
    @asset = Asset.new(asset_params)
    @event = @asset.event
    @asset.user = current_user

    if @asset.save
      redirect_to event_path(@event), notice: 'Asset was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /assets/1
  def update
    if @asset.update(asset_params)
      url = if @asset.event.nil?
              asset_path(@asset)
            else
              url_for controller: 'events', id: @asset.event_id, action: 'show', anchor: 'eventuploads', only_path: true
      end
      redirect_to url, notice: 'Asset was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /assets/1
  def destroy
    @event = @asset.event
    @asset.destroy
    url = url_for controller: 'events', id: @event.id, action: 'show', anchor: 'eventuploads', only_path: true
    redirect_to url, notice: 'Asset was successfully deleted.'
  end

  # DELETE /assets/1
  def destroyall
    Asset.delete_all
    redirect_to assets_path, notice: 'Assets where successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_asset
    @asset = Asset.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def asset_params
    params.require(:asset).permit(:name, :asset, :comments, :status, :event_id, :eventstatus_id, :eventsession_id)
  end
end
