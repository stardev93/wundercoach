class Account < ApplicationRecord
  # Update ActiveCampaign related data like api key
  class ActiveCampaignsController < ApplicationController
    # the List struct offers accessors for id and name, as needed by simple form to build a list select field
    List = Struct.new(:id, :name)

    # GET /account/active_campaign
    def show
      if @account.active_campaign_default_list.present?
        @list = active_campaign_lists.find {|elem| elem['id'] == @account.active_campaign_default_list }
      end
    end

    # GET /account/active_campaign/edit
    def edit
      @form = ActiveCampaignForm.new(@account)
      @lists = active_campaign_lists.map {|hash| List.new(hash['id'], hash['name']) } if @account.active_campaign_integrated?
    end

    # PATCH/PUT /account/active_campaign
    def update
      result = UpdateActiveCampaign.call(params[:account], 'model' => @account)
      if result.success?
        redirect_to account_active_campaign_url, notice: t(:update_successful)
      else
        @form = result['contract.default']
        render action: 'edit'
      end
    end

    # DELETE /account/active_campaign
    def destroy
      @account.update!({
        active_campaign_api_endpoint: nil,
        active_campaign_api_key: nil,
        active_campaign_default_list: nil
      })
      redirect_to account_active_campaign_url, notice: t(:delete_successful)
    end

    private

    def active_campaign_lists
      @account.active_campaign_client.list_list(ids: 'all')['results']
    end
  end
end
