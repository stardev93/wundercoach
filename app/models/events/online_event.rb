# OnlineEvents do not use locations
class OnlineEvent < Event

  #validates :webinar_url, :webinar_provider, presence: true
  #validates :maxparticipants, presence: true, numericality: { greater_than_or_equal_to: 0 }
  belongs_to :eventtemplate, class_name: "Eventtemplate", foreign_key: "eventtemplate_id"

  # required by url_helpers
  def self.model_name
    Event.model_name
  end

end
