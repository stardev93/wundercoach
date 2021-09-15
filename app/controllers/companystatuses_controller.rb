class CompanystatusesController < ApplicationController
  before_action :set_companystatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /companystatuses
  def index
    @companystatuses = if params[:search]
                         Companystatus.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
                       else
                         Companystatus.page(params[:page]).order('name ASC')
    end
  end

  # GET /companystatuses/1
  def show; end

  # GET /companystatuses/new
  def new
    @companystatus = Companystatus.new
  end

  # GET /companystatuses/1/edit
  def edit; end

  # POST /companystatuses
  def create
    @companystatus = Companystatus.new(companystatus_params)
    if @companystatus.save
      redirect_to @companystatus, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /companystatuses/1
  def update
    if @companystatus.update(companystatus_params)
      redirect_to @companystatus, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /companystatuses/1
  def destroy
    @companystatus.destroy
    redirect_to companystatuses_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_companystatus
    @companystatus = Companystatus.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def companystatus_params
    params.require(:companystatus).permit(:name, :description, :key)
  end
end
