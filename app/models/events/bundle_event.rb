# a StandardEvent occurs at a specific time and costs money
# it can be booked online and has multiple attendants from multiple clients
class BundleEvent < Event

  # Associations
  belongs_to :durationunit
  belongs_to :eventtemplate, class_name: "Eventtemplate", foreign_key: "eventtemplate_id"
  belongs_to :planningstatus
  belongs_to :onlinestatus
  belongs_to :vat
  belongs_to :eventtype
  belongs_to :product_location, class_name: 'Product::Location'

  has_many :eventpaymentmethods, dependent: :destroy, foreign_key: 'event_id'
  has_many :paymentmethods, through: :eventpaymentmethods, foreign_key: 'event_id'

  #has_many :eventbookings, through: :subevents, :source => :event
  #has_many :completed_eventbookings, -> { completed }, class_name: 'Eventbooking', foreign_key: 'event_id'

  has_many :subevents, class_name: "EventSubevent", foreign_key: "event_id", dependent: :destroy

  has_many :taggings, class_name: 'Product::Tagging', foreign_key: 'event_id', dependent: :destroy
  has_many :tags, class_name: 'Product::Tag', foreign_key: 'event_id', through: :taggings

  has_many :affiliate_taggings, class_name: 'Affiliate::Tagging', foreign_key: 'event_id', dependent: :destroy
  has_many :affiliate_tags, class_name: 'Affiliate::Tag', foreign_key: 'event_id', through: :affiliate_taggings, source: 'tag'

  has_and_belongs_to_many :coaches, foreign_key: 'event_id'

  # required by url_helpers
  def self.model_name
    Event.model_name
  end

  def get_subevents
    subevents.by_date
  end

  def get_subevent_total
    p = 0
    subevents.each do |subevent|
      p = p + subevent.subevent.price
    end
    return p
  end

  # Delegates the ordering of a bundle to all associated Events
  # order.product of a BundleEvent is related to BundleEvent
  def create_eventbooking(order)
    @order = EventbookingService.new.book_event(order)
  end

  # returns true if any free seats are avalaible
  def free_seats?
    free_seats = false
    subevents.each do |subevent|
      free_seats = subevent.subevent.free_seats?
      break if !free_seats
    end
    return free_seats
  end

  # get free seats from subevents
  def seats_free
    subevents.map(&:seats_free).min || 0
  end

end
