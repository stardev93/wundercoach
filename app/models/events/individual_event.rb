# IndividualEvent is an event
# - can not be booked directly.
# - client can make a booking request and schedule an appointment
# - has one or multiple attendants from one client

# you can contact your coach for an IndividualEvent
# IndividualEvents can be booked anytime, they don't have seats or a fixed date
# you can't simply book them, get in contact and make an appointment
class IndividualEvent < Event
  has_many :requests, foreign_key: "event_id", dependent: :destroy
  belongs_to :eventtemplate, class_name: "Eventtemplate", foreign_key: "eventtemplate_id", required: false
  validates :maxparticipants, :full_price, presence: true

  # free individual events are allowed, so price can be 0
  validates :full_price, numericality: { greater_than_or_equal_to: 0 }
  validates :maxparticipants, numericality: { greater_than_or_equal_to: 0 }

  # required by url_helpers
  def self.model_name
    Event.model_name
  end

  def date?
    false
  end

  def order_allowed?
    false
  end

  def early_booking_price_applies?
    false
  end
end
