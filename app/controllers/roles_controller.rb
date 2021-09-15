class RolesController < ApplicationController
  before_action :set_role, only: %i(show edit update destroy)
  authorize_resource

  # GET /roles
  def index
    @roles = if params[:search]
               Role.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
             else
               Role.page(params[:page]).order('name ASC')
    end
  end

  # GET /roles/1
  def show; end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit; end

  # POST /roles
  def create
    @role = Role.new(role_params)
    if @role.save
      redirect_to @role, notice: 'Role was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /roles/1
  def update
    if @role.update(role_params)
      redirect_to @role, notice: 'Role was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /roles/1
  def destroy
    @role.destroy
    redirect_to roles_url, notice: 'Role was successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_role
    @role = Role.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def role_params
    params.require(:role).permit(:name, :desc)
  end
end
