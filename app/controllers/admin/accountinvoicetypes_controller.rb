class AccountinvoicetypesController < ApplicationController
  before_action :set_accountinvoicetype, only: %i(show edit update destroy)
  authorize_resource

  # GET /accountinvoicetypes
  def index
    @accountinvoicetypes = Accountinvoicetype.with_translations(I18n.locale).page(params[:page]).order('name ASC')
    @accountinvoicetypes = @accountinvoicetypes.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
  end

  # GET /accountinvoicetypes/1
  def show; end

  # GET /accountinvoicetypes/new
  def new
    @accountinvoicetype = Accountinvoicetype.new
  end

  # GET /accountinvoicetypes/1/edit
  def edit; end

  # POST /accountinvoicetypes
  def create
    @accountinvoicetype = Accountinvoicetype.new(accountinvoicetype_params)
    if @accountinvoicetype.save
      redirect_to accountinvoicetypes_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /accountinvoicetypes/1
  def update
    if @accountinvoicetype.update(accountinvoicetype_params)
      redirect_to accountinvoicetypes_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /accountinvoicetypes/1
  def destroy
    @accountinvoicetype.destroy
    redirect_to accountinvoicetypes_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accountinvoicetype
    @accountinvoicetype = Accountinvoicetype.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def accountinvoicetype_params
    params.require(:accountinvoicetype).permit(:key, :name, :description, :position)
  end
end
