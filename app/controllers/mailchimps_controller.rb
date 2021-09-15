# manages mailchimp api preferences and syncing contacts
class MailchimpsController < ApplicationController
  before_action :set_mailchimp, only: %i(show edit update destroy sync)
  before_action -> { require_feature('crm_functions') }
  load_and_authorize_resource

  # GET /mailchimp
  def show
    @mailchimp = Mailchimp.first
    redirect_to new_mailchimp_path if @mailchimp.blank?
  end

  # GET /mailchimp/new
  def new
    @mailchimp = Mailchimp.new
  end

  # GET /mailchimp/edit
  def edit; end

  # POST /mailchimp
  def create
    @mailchimp = Mailchimp.new(mailchimp_params)
    if @mailchimp.save
      redirect_to mailchimp_path, notice: t(:mailchimp_integrated_successfully)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /mailchimp
  def update
    if @mailchimp.update(mailchimp_params)
      redirect_to mailchimp_path, notice: t(:mailchimp_updated_successfully)
    else
      render action: 'edit'
    end
  end

  # DELETE /mailchimp
  def destroy
    @mailchimp.destroy
    redirect_to marketing_url, notice: t(:mailchimp_disconnected_successfully)
  end

  # POST /mailchimp/sync
  def sync
    authorize_feature! 'crm_functions'
    @mailchimp.sync_from_wundercoach_to_mailchimp
    @mailchimp.touch(:last_sync) # saves timestamp of last sync
    redirect_to mailchimp_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mailchimp
    @mailchimp = Mailchimp.first
  end

  # Only allow a trusted parameter "white list" through.
  def mailchimp_params
    params.require(:mailchimp).permit(:api_key, :list_id)
  end
end
