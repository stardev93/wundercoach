class Admin::FeaturesController < Admin::AdminController
  before_action :set_feature, only: %i(show edit update destroy sort_down sort_up position populate)
  authorize_resource

  # GET /features
  def index
    @features = Feature.with_translations(I18n.locale).page(params[:page]).order('feature_translations.name ASC')
    @features = @features.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /features/1
  def show; end

  # GET /features/new
  def new
    @feature = Feature.new
    @feature.fieldtype = "boolean"
    if params[:appversion]
      @appversion = Appversion.find(params[:appversion])
      @feature.appversion = @appversion
    end
  end

  # GET /features/populate
  def populate
    Paymentplan.where(appversion: @feature.appversion).all.each do |paymentplan|
      begin
        Paymentplanfeature.create!([{paymentplan: paymentplan, feature: @feature}])
      rescue
        next
      end
    end
    redirect_to admin_paymentplanfeatures_path, notice: t(:creation_successful)
  end

  # GET /features/1/edit
  def edit; end

  # POST /features
  def create
    @feature = Feature.new(feature_params)
    if @feature.save
      redirect_to admin_features_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /features/1
  def update
    if @feature.update(feature_params)
      redirect_to admin_features_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  def position
    @feature.remove_from_list
    @feature.insert_at(params[:position])
    # @feature.update_attribute :position_position, params[:position]
    render nothing: true
  end

  # DELETE /features/1
  def destroy
    @feature.destroy
    redirect_to admin_paymentplanfeatures_url, notice: t(:delete_successful)
  end

  def sort_down
    @feature.position = @feature.position + 1
    @feature.save
    redirect_to paymentplanfeatures_path
  end

  def sort_up
    @feature.position = @feature.position - 1
    @feature.save
    redirect_to paymentplanfeatures_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_feature
    @feature = Feature.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def feature_params
    params.require(:feature).permit(:key, :name, :description, :position, :appversion_id, :fieldtype)
  end
end
