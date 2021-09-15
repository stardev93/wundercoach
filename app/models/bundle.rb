# A Bundle of events
# acts as a product
class Bundle < ActiveRecord::Base
  acts_as_tenant(:account)
  has_many :businessdocumentpositions, as: :product
  has_and_belongs_to_many :events, -> { show_in_bundle }
  has_and_belongs_to_many :paymentmethods
  belongs_to :vat
  belongs_to :onlinestatus, -> { available_for_bundles }
  has_many :orders, as: :product

  nilify_blanks only: %i(name shortdescription longdescription digimember_id)

  validates :name, presence: true
  validates_length_of :name, :slug, maximum: 255
  validates_presence_of :paymentmethods
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  include Filterable
  include ActsAsProduct
  extend FriendlyId
  friendly_id :slug_candidates, use: %i(slugged finders)

  monetize :price_cents, with_model_currency: :currency

  scope :online, -> { joins(:onlinestatus).merge(Onlinestatus.online) }

  def slug_candidates
    [:name, %i(name id)]
  end

  def additional_participants?
    false
  end

  # ToDo: allow additional participants for bundles
  # return the number of available seats for additional participants
  def additional_participants_available
    if additional_participants?
      0
    else
      0
    end
  end

  def available_events
    Event.available_for_bundle(self)
  end

  # TODO: turn this into an editable attribute
  def show_remaining_seats_count
    false
  end

  # once we introduce vouchers, early_booking or other methods to reduce a price,
  # this is the only method that returns the full price
  def full_price
    price
  end

  def to_s
    name
  end

  def free?
    price.zero?
  end

  def show_free_seats?
    show_remaining_seats_count
  end

  def seats_free
    events.map(&:seats_free).min || 0
  end

  # get the number of booked seats for this bundle
  # i.e. eventbookings with status confirmed waiting + additional_participants
  def seats_booked
    maxparticipants - seats_free
  end

  # get the smallest number of maxparticipants from subevents
  def maxparticipants
    events.order("maxparticipants ASC").first.maxparticipants || 0
  end

  # Delegates the order to all associated Events
  # this model is not used anymore, look at BundleEvent
  def create_eventbooking(order)
    events.each do |event|
      event.create_eventbooking(order)
    end
  end

  def seats_limited?
    true
  end

  # returns minimum remaining_bookings_count from events
  # uses caching
  def remaining_bookings_count
    @remaining_bookings_count ||= events.map(&:seats_free).min || 0
  end

  def reservation_expiry
    events.map(&:start_date).min - 1.days
  end

  def free_seats?
    remaining_bookings_count.positive?
  end

  def bookable?
    free_seats?
  end

  def online?
    events.all?(&:online?)
  end

  # By default available until 24h before the first event starts
  def available_until
    events.reorder(start_date: :desc).first.start_date - 1.day
  end

  def start_date
    if events.order('events.start_date').first
      events.order('events.start_date').first.start_date
    end
  end
  def end_date
    if events.order('events.end_date DESC').last
      events.order('events.end_date DESC').last.end_date
    end
  end
  def vat_included?
    self.account.vat_included
  end
  # return the value of vat object assigned to event
  # this should be in class BaseEvent I guess...
  def vat_rate
    if vat
      vat.value.to_f
    else
      0
    end
  end

  # return the vat sum of event price
  def vat_sum
    val = 0
    if vat
      # vat is included in price, i.e. net price = price / (1 + vat.value)
      if vat_included? && vat.value != 0
        val = price - (price / (1 + vat.value))
      # vat is not included in price, i.e. net_price = price * vat.value
      else
        val = price * vat_rate
      end
    else
      val = 0
    end
    return val
  end

  def net_price
    if vat_included?
      gross_price - vat_sum
    else
      price
    end
  end

  def gross_price
    if vat_included?
      price
    else
      price + vat_sum
    end
  end

  # slug generation with friendly_id
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
    #|| name_changed?
  end

  def multipricing?
    false
  end
end
