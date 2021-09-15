# handles crud operations for bundles
class BundlesController < ApplicationController
  before_action :set_bundle, only: %i(show edit update destroy)

  # GET /bundles
  def index
    # @bundles = Bundle.page(params[:page]).order('name ASC')
    # @bundles = @bundles.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
    redirect_to events_path + "?q[type_eq]=BundleEvent"
  end

  # GET /bundles/1
  def show
    redirect_to events_path + "?q[type_eq]=BundleEvent"
    # @bundle = @bundle.decorate
    #
    # @available_events = Event.page(params[:page]).future_events.with_includes.no_eventtemplates.by_start_date
    # @available_events = @available_events.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
  end

  # GET /bundles/new
  def new
    redirect_to events_path + "?q[type_eq]=BundleEvent"
    # @bundle = Bundle.new
  end

  # GET /bundles/1/edit
  def edit
    redirect_to events_path + "?q[type_eq]=BundleEvent"
  end

  # # POST /bundles
  # def create
  #   @bundle = Bundle.new(bundle_params)
  #   if @bundle.save
  #     redirect_to @bundle, notice: t(:creation_successful)
  #   else
  #     render action: 'new'
  #   end
  # end
  #
  # # PATCH/PUT /bundles/1
  # def update
  #   if @bundle.update(bundle_params)
  #     redirect_to @bundle, notice: t(:update_successful)
  #   else
  #     render action: 'edit'
  #   end
  # end

  # # DELETE /bundles/1
  # def destroy
  #   @bundle.destroy
  #   redirect_to bundles_url, notice: t(:delete_successful)
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  # def set_bundle
  #   @bundle = Bundle.find(params[:id])
  # end
  #
  # # Only allow a trusted parameter "white list" through.
  # def bundle_params
  #   params.require(:bundle).permit(
  #     :name, :slug, :shortdescription, :price, :currency, :vat_id, :generate_invoice,
  #     :longdescription, :allow_signup, :bottom_text, :onlinestatus_id,
  #     :digimember_id, paymentmethod_ids: []
  #   )
  # end
end
