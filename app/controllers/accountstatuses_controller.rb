class AccountstatusesController < ApplicationController
  before_action :set_accountstatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /accountstatuses
  def index
    @accountstatuses = Accountstatus.with_translations(I18n.locale).page(params[:page])
    @accountstatuses = @accountstatuses.where("name LIKE ?", "%#{params[:search]}%").order('name ASC') if params[:search]
  end

  # GET /accountstatuses/1
  def show; end

  # GET /accountstatuses/new
  def new
    @accountstatus = Accountstatus.new
  end

  # GET /accountstatuses/1/edit
  def edit; end

  # POST /accountstatuses
  def create
    @accountstatus = Accountstatus.new(accountstatus_params)
    if @accountstatus.save
      redirect_to @accountstatus, notice: t(:accountstatus_successfully_created)
    else
      render action: "new"
    end
  end

  # PATCH/PUT /accountstatuses/1
  def update
    if @accountstatus.update(accountstatus_params)
      redirect_to @accountstatus, notice: t(:accountstatus_successfully_updated)
    else
      render action: "edit"
    end
  end

  # DELETE /accountstatuses/1
  def destroy
    @accountstatus.destroy
    redirect_to accountstatuses_url, notice: t(:accountstatus_successfully_deleted)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accountstatus
    @accountstatus = Accountstatus.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def accountstatus_params
    params.require(:accountstatus).permit(:key, :sortorder, :name, :comments)
  end
end
