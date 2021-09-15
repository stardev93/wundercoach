class Admin::AppversionsController < Admin::AdminController
  before_action :set_appversion, only: %i(show edit update destroy)
  authorize_resource

  # GET /appversions
  def index
    @appversions = Appversion.page(params[:page]).order('name ASC')
    @appversions = @appversions.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /appversions/1
  def show; end

  # GET /appversions/new
  def new
    @appversion = Appversion.new
  end

  # GET /appversions/1/edit
  def edit; end

  # POST /appversions
  def create
    @appversion = Appversion.new(appversion_params)

    if @appversion.save
      redirect_to admin_appversions_url, notice: 'Appversion was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /appversions/1
  def update
    if @appversion.update(appversion_params)
      redirect_to admin_appversions_url, notice: 'Appversion was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /appversions/1
  def destroy
    @appversion.destroy
    redirect_to admin_appversions_url, notice: 'Appversion was successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_appversion
    @appversion = Appversion.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def appversion_params
    params.require(:appversion).permit(:name, :version_number, :version_string, :status)
  end
end
