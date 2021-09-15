# filter by campaign participation
class CampaignFilter < Filter
  def self.model_name
    Filter.model_name
  end

  belongs_to :campaign

  validates :campaign_id, presence: true

  def scope_name
    :filter_by_campaign
  end

  def scope_params
    [campaign_id]
  end
end
