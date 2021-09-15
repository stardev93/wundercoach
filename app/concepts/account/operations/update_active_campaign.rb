class Account < ApplicationRecord
  # Update ActiveCampaign data
  class UpdateActiveCampaign < Trailblazer::Operation
    step Contract::Build(constant: ActiveCampaignForm)
    step Contract::Validate()
    # TODO: Check if we can access the api with the provided data
    step Contract::Persist()
  end
end
