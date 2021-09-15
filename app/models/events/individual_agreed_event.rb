# if you make a booking for an IndividualEvent, an IndividualAgreedEvent will
# be spawned. Bookings belong to the IndividualAgreedEvent,
# and it has a date and a price. Since this is a privat event, it does not
# appear in signup
class IndividualAgreedEvent < Event
  # you will usually create an agreed event using one form
  accepts_nested_attributes_for :orders

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :start_date, presence: true

  belongs_to :eventtemplate, class_name: "Eventtemplate", foreign_key: "eventtemplate_id", required: false
  has_one :request, foreign_key: :generated_event_id, dependent: :nullify

  before_create :set_paymentmethods

  # required by url_helpers
  def self.model_name
    Event.model_name
  end

  #ToDo: this can be done smarter, combine it with self.new_from_request(request)
  # create new from event, give event data
  def self.new_from_event(coaching)
    event = IndividualAgreedEvent.new({
      name: coaching.name,
      start_date: (Time.now + 7.day).strftime("%Y-%m-%d 10:00:00"),
      end_date: (Time.now + 7.day).strftime("%Y-%m-%d 18:00:00")
    })
    event.eventbookings.build({ booking_date: Time.now })
    event
  end

  #ToDo: this can be done smarter, combine it with self.new_from_event(coaching)
  # create new from request, give customer (request) data
  def self.new_from_request(request)
    event = IndividualAgreedEvent.new({
      name: "#{request.event.name} - #{request.full_name}",
      slug: "#{request.event.slug}",
      start_date: (Time.now + 7.day).strftime("%Y-%m-%d 10:00:00"),
      end_date: (Time.now + 7.day).strftime("%Y-%m-%d 18:00:00"),
      request: request
    })
    event.orders.build({
      order_date: Time.now,
      address_attributes: {
        lastname: request.lastname,
        firstname: request.firstname,
        gender: request.gender,
        telephone: request.tel,
        email: request.email
      }
    })
    event
  end

  def order_allowed?
    false
  end

  # set default values
  def setup
    super
    assign_attributes({
      onlinestatus: Onlinestatus.find_by(key: 'offline')
    })
  end

  private

  def set_paymentmethods
    paymentmethods << Paymentmethod.find_by(key: 'vorkasse')
  end
end
