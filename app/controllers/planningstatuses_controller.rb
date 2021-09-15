class PlanningstatusesController < ApplicationController
  before_action :set_planningstatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /planningstatuses
  def index
    @planningstatuses = if params[:search]
                          Planningstatus.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
                        else
                          Planningstatus.page(params[:page]).order('name ASC')
    end
  end

  # GET /planningstatuses/1
  def show; end

  # GET /planningstatuses/new
  def new
    @planningstatus = Planningstatus.new
  end

  # GET /planningstatuses/1/edit
  def edit; end

  # POST /planningstatuses
  def create
    @planningstatus = Planningstatus.new(planningstatus_params)

    if @planningstatus.save
      redirect_to planningstatuses_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /planningstatuses/1
  def update
    if @planningstatus.update(planningstatus_params)
      redirect_to planningstatuses_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /planningstatuses/1
  def destroy
    @planningstatus.destroy
    redirect_to planningstatuses_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_planningstatus
    @planningstatus = Planningstatus.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def planningstatus_params
    params.require(:planningstatus).permit(:key, :name, :description, :position, :icon, :color)
  end
end
