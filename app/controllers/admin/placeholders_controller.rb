class Admin::PlaceholdersController < Admin::AdminController
  before_action :set_placeholder, only: %i(show edit update destroy)
  authorize_resource

  # GET /placeholders
  def index
    @placeholders = if params[:search]
          Placeholder.by_objecttype.by_sortorder.by_name.where("name LIKE ?", "%#{params[:search]}%")
            else
          Placeholder.by_objecttype.by_sortorder.by_name
    end
  end

  # GET /placeholders/1
  def show; end

  # GET /placeholders/new
  def new
    @placeholder = Placeholder.new
  end

  # GET /placeholders/1/edit
  def edit; end

  # POST /placeholders
  def create
    @placeholder = Placeholder.new(placeholder_params)

    if @placeholder.save
      redirect_to admin_placeholder_path(@placeholder), notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /placeholders/1
  def update
    if @placeholder.update(placeholder_params)
      redirect_to admin_placeholder_path(@placeholder), notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /placeholders/1
  def destroy
    @placeholder.destroy
    redirect_to admin_placeholders_path, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_placeholder
    @placeholder = Placeholder.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def placeholder_params
    params.require(:placeholder).permit(:name, :description, :localisation_type, :display_name, :objecttype, :sortorder)
  end
end
