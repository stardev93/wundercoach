# manages campaigns from creation to sync with third party crm tool
class CampaignsController < ApplicationController
  before_action -> { require_feature('crm_functions') }
  load_and_authorize_resource

  # GET /campaigns
  def index
    @campaigns = Campaign.page(params[:page])
  end

  # POST /campaigns/1/sync
  def sync
    authorize_feature! 'crm_functions'
    notice = I18n.t(:campaign_sync_success)
    if !@account.mailchimp_integrated?
      notice = I18n.t(:integrate_mailchimp_first)
    elsif @campaign.syncable?
      @campaign.sync!
    else
      notice = I18n.t(:campaign_not_ready_for_sync)
    end
    redirect_to @campaign, notice: notice
  end

  # GET /campaigns/1
  def show
    @available_target_groups = TargetGroup.where.not(id: @campaign.target_groups.pluck(:id))
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
  end

  # GET /campaigns/1/edit
  def edit; end

  # POST /campaigns
  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      redirect_to @campaign, notice: t(:campaign_successfully_created)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /campaigns/1
  def update
    if @campaign.update(campaign_params)
      redirect_to @campaign, notice: t(:campaign_successfully_updated)
    else
      render action: 'edit'
    end
  end

  # DELETE /campaigns/1
  def destroy
    @campaign.destroy
    redirect_to campaigns_url, notice: t(:campaign_successfully_deleted)
  end

  def remove_target_group
    target_group = @campaign.target_groups.find(params[:target_group_id])
    @campaign.target_groups.delete(target_group)
    redirect_to :back
  end

  def add_target_group
    target_group = TargetGroup.find(params[:target_group_id])
    @campaign.target_groups << target_group
    @campaign.save!
    redirect_to :back
  end

  private

  # Only allow a trusted parameter "white list" through.
  def campaign_params
    params.require(:campaign).permit(:name, :target_group_id)
  end
end
