class AccounttypesController < ApplicationController
  before_action :set_accounttype, only: %i(show edit update destroy)
  authorize_resource

  # GET /accounttypes
  def index
    @accounttypes = Accounttype.page(params[:page]).order("name ASC")
    @accounttypes = @accounttypes.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /accounttypes/1
  def show; end

  # GET /accounttypes/new
  def new
    @accounttype = Accounttype.new
  end

  # GET /accounttypes/1/edit
  def edit; end

  # POST /accounttypes
  def create
    @accounttype = Accounttype.new(accounttype_params)
    if @accounttype.save
      redirect_to @accounttype, notice: 'Accounttype was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /accounttypes/1
  def update
    if @accounttype.update(accounttype_params)
      redirect_to @accounttype, notice: 'Accounttype was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /accounttypes/1
  def destroy
    @accounttype.destroy
    redirect_to accounttypes_url, notice: 'Accounttype was successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accounttype
    @accounttype = Accounttype.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def accounttype_params
    params.require(:accounttype).permit(:name, :description, :key)
  end
end
