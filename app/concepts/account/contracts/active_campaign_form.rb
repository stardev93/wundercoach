class Account < ApplicationRecord
  # Validate ActiveCampaign related data
  class ActiveCampaignForm < Reform::Form
    property :active_campaign_api_endpoint
    property :active_campaign_api_key
    property :active_campaign_default_list

    validates :active_campaign_api_endpoint, :active_campaign_api_key, presence: true
  end
end
