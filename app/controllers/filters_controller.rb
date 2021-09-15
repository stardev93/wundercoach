# crud operartions for all kinds of filters
class FiltersController < ApplicationController
  load_and_authorize_resource
  before_action :set_target_group, only: %i(index new create)
  before_action :set_campaign, only: %i(index new create)

  # GET /filters
  def index
    @filters = Filter.paginate(page: params[:page]).decorate
  end

  # GET /filters/new
  def new
    filter_type =
      case params[:type]
      when 'type'
        'TypeFilter'
      when 'location'
        'LocationFilter'
      when 'campaign'
        'CampaignFilter'
      else
        'PriceFilter'
      end
    @filter = Filter.new(type: filter_type)
  end

  # GET /filters/1
  def show; end

  # GET /filters/1/edit
  def edit; end

  # POST /filters
  def create
    @filter = Filter.new(filter_params)
    # since only PriceFilter monetizes price_cents, we must set the price
    # explicitly, once @filter has become an instance of PriceFilter
    @filter.price = filter_params['price'] if @filter.is_a? PriceFilter
    redirection_url = filters_url
    if @target_group.present?
      @filter.target_groups << @target_group
      redirection_url = @target_group
    end
    redirection_url = @campaign if @campaign.present?
    if @filter.save
      redirect_to redirection_url, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /filters/1
  def update
    if @filter.update(filter_params)
      redirect_to @filter, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /filters/1
  def destroy
    @filter.destroy
    redirect_to filters_url, notice: t(:delete_successful)
  end

  private

  def set_target_group
    @target_group = TargetGroup.find(params[:target_group_id]) unless params[:target_group_id].blank?
  end

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id]) unless params[:campaign_id].blank?
  end

  # Only allow a trusted parameter "white list" through.
  def filter_params
    params.require(:filter).permit(:name, :type, :price, :comparator, :location,
                                   :distance, :campaign_id, :eventtype_id)
  end
end
