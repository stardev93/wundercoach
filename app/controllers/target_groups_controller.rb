class TargetGroupsController < ApplicationController
  load_and_authorize_resource
  before_action :set_campaign, only: %i(new create)

  # GET /target_groups
  def index
    @target_groups = if params[:search]
                       TargetGroup.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
                     else
                       TargetGroup.page(params[:page]).order('name ASC')
    end
  end

  # GET /target_groups/1
  def show
    @filters = @target_group.filters
    @available_filters = Filter.where.not(id: @filters.pluck(:id))
    @filters = @filters.decorate
  end

  # GET /target_groups/new
  def new
    @target_group = TargetGroup.new
  end

  # GET /target_groups/1/edit
  def edit; end

  # POST /target_groups
  def create
    @target_group = TargetGroup.new(target_group_params)
    @target_group.campaigns << @campaign if @campaign
    if @target_group.save
      redirect_to (@campaign || @target_group), notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /target_groups/1
  def update
    if @target_group.update(target_group_params)
      redirect_to @target_group, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /target_groups/1
  def destroy
    @target_group.destroy
    redirect_to target_groups_url, notice: t(:delete_successful)
  end

  def remove_filter
    filter = @target_group.filters.find(params[:filter_id])
    @target_group.filters.delete(filter)
    redirect_to :back
  end

  def add_filter
    filter = Filter.find(params[:filter_id])
    @target_group.filters << filter
    @target_group.save!
    redirect_to :back
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id]) unless params[:campaign_id].blank?
  end

  # Only allow a trusted parameter "white list" through.
  def target_group_params
    params.require(:target_group).permit(:name, :filter_id)
  end
end
