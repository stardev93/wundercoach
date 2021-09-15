class VatsController < ApplicationController
  before_action :set_vat, only: %i(show edit update destroy)
  authorize_resource

  # GET /vats
  def index
    @vats = current_tenant.custom_vats.page(params[:page])
  end

  # GET /vats/new
  def new
    @vat = Vat.new
  end

  # GET /vats/1/edit
  def edit; end

  # POST /vats
  def create
    @vat = Vat.new(vat_params)
    @vat.account = current_tenant
    if @vat.save
      redirect_to vats_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /vats/1
  def update
    if @vat.update(vat_params)
      redirect_to vats_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /vats/1
  def destroy
    @vat.destroy
    redirect_to vats_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_vat
    @vat = current_tenant.custom_vats.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def vat_params
    params.require(:vat).permit(:name, :value)
  end
end
