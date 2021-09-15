class UserrolesController < ApplicationController
  before_action :set_userrole, only: %i(show edit update destroy)
  authorize_resource

  # GET /userroles
  def index
    @userroles = if params[:search]
                   Userrole.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
                 else
                   Userrole.page(params[:page]).order('name ASC')
    end
  end

  # GET /userroles/1
  def show; end

  # GET /userroles/new
  def new
    @userrole = Userrole.new
  end

  # GET /userroles/1/edit
  def edit; end

  # POST /userroles
  def create
    @userrole = Userrole.new(userrole_params)

    if @userrole.save
      redirect_to @userrole, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /userroles/1
  def update
    if @userrole.update(userrole_params)
      redirect_to @userrole, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /userroles/1
  def destroy
    @userrole.destroy
    redirect_to userroles_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_userrole
    @userrole = Userrole.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def userrole_params
    params.require(:userrole).permit(:user_id, :role_id)
  end
end
