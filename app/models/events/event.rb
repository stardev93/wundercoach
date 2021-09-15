# Main Event Object. Instances are based on subclasses, via STI single table inheritance.
require "#{Rails.root}/app/services/billing/eventbooking_service"

class Event < ActiveRecord::Base
  acts_as_tenant(:account)

  # includes
  include HasCountry
  include Filterable
  include ActsAsProduct

  # Associations
  # belongs to
  belongs_to :durationunit
  belongs_to :eventtype
  belongs_to :onlinestatus
  belongs_to :planningstatus
  belongs_to :pricingset, class_name: 'Product::Pricingset', foreign_key: "product_pricingset_id", required: false
  belongs_to :product_location, class_name: 'Product::Location', foreign_key: "product_location_id", required: false
  belongs_to :vat
  belongs_to :eventtemplate

  # Associations
  # has_many
  has_many :affiliate_taggings, class_name: 'Affiliate::Tagging', dependent: :destroy
  has_many :affiliate_tags, class_name: 'Affiliate::Tag', through: :affiliate_taggings, source: 'tag'
  has_many :allowed_eventpaymentmethods, -> { where('available_until IS NULL OR available_until > ?', DateTime.now) }, class_name: 'Eventpaymentmethod', dependent: :destroy
  has_many :assets, dependent: :destroy
  has_many :businessdocumentpositions, as: :product
  has_many :completed_eventbookings, -> { completed }, class_name: 'Eventbooking' # scope hides incomplete eventbookings
  has_many :eventbookings, dependent: :destroy
  has_many :eventpaymentmethods, dependent: :destroy
  has_many :invoices, through: :eventbookings
  has_many :orders, as: :product, dependent: :destroy
  has_many :paymentmethods, through: :eventpaymentmethods
  has_many :product_taggings, class_name: "Product::Tagging", dependent: :destroy, source: :tag
  has_many :product_tags, class_name: "Product::Tag", through: :product_taggings, source: :tag

  # has_and_belongs_to_many :bundles

  # Associations
  # has_and_belongs_to_many
  has_and_belongs_to_many :coaches
  has_many :bundleevents, dependent: :destroy, class_name: "EventSubevent", foreign_key: "subevent_id"
  has_many :events, through: :bundleevents, foreign_key: "subevent_id"


  # Geocoding
  geocoded_by :full_street_address
  after_validation :geocode, unless: "geocoded? || full_street_address.nil?"
  after_validation :clear_coordinates, if: "geocoded? && full_street_address.nil?"

  acts_as_mappable default_units: :kms,
                   default_formula: :sphere,
                   lat_column_name: :latitude,
                   lng_column_name: :longitude

  # Validations
  validates :name, :eventtype, presence: true
  validates_length_of :name, :slug, maximum: 255
  validates :slug, uniqueness: true
  validates_associated :eventtype
  validates :max_additional_participants, presence: true

  validates_with FriendlyUrlValidator

  validates_associated :eventpaymentmethods

  # ToDo: refine this to allow non-free events with multiple participants
  # today additional_participants don't get billed
  validate :max_additional_participants_for_free_events_only

  # Other
  nilify_blanks only: %i(digimember_id)
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  monetize :full_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :price_early_signup_cents, with_model_currency: :currency, allow_nil: true

  accepts_nested_attributes_for :eventpaymentmethods

  # Hooks
  before_save :set_values
  after_commit :update_parent_event

  # Scopes
  #default_scope { order('events.start_date, events.name') }
  scope :with_includes, -> { includes(:product_location, :product_tags, :coaches, onlinestatus: :translations, planningstatus: :translations, eventtype: :translations, durationunit: :translations) }
  scope :no_eventtemplates, -> { where("type != 'Eventtemplate'") }
  scope :eventtemplates, -> { where("type = 'Eventtemplate'") }
  scope :by_start_date, -> { order('events.start_date, events.name') }
  scope :by_name, -> { order('events.name ASC') }

  scope :online, -> { joins(:onlinestatus).merge(Onlinestatus.online) }
  scope :signupallowed, -> { where(allow_signup: true) }
  scope :planned, -> { joins(:planningstatus).merge(Planningstatus.planned) }
  scope :show_in_bundle, -> { joins(:onlinestatus).merge(Onlinestatus.show_in_bundle) }
  scope :available_for_bundles, -> { future_events.public_events.show_in_bundle }
  scope :available_for_bundle, ->(bundle) { available_for_bundles.where.not(id: bundle.events.pluck(:id)) }

  scope :future_events, -> { where('start_date >= ?', Date.today) }
  scope :next_events, -> { planned.limit(10) }
  scope :online_events, -> { future_events.online }

  # For hiding some events in signup
  scope :public_events, -> { where.not(type: %w(IndividualAgreedEvent IndividualEvent)) }

  scope :group_events, -> { where(type: %w(StandardEvent FreeEvent BundleEvent)) }
  scope :individual_events, -> { where(type: 'IndividualAgreedEvent') }

  scope :upcoming, -> { planned.future_events.where.not(start_date: nil) }
  scope :by_account, ->(account_id) { where(account_id: account_id) }
  scope :by_affiliate_tags, ->(tag_ids) { joins(:affiliate_tags).where(affiliate_tags: { id: tag_ids }) }

  scope :standard_events, -> { where(type: %w(StandardEvent)) }
  scope :free_events, -> { where(type: %w(FreeEvent)) }
  scope :individual_events, -> { where(type: %w(IndividualEvent)) }
  scope :individual_agreed_events, -> { where(type: %w(IndividualAgreedEvent)) }
  scope :bundle_events, -> { where(type: %w(BundleEvent)) }
  scope :eventtemplate_events, -> { where(type: %w(Eventtemplate)) }

  scope :subevent_candidates, -> { where(type: %w(StandardEvent FreeEvent IndividualEvent OnlineEvent)) }
  scope :available_as_subevents, -> { subevent_candidates }

  # The following Scopes were used as filters in the signup index action
  # currently filtering is disabled in signup#index
  scope :search, lambda {|search_term|
    # Join tags via LEFT JOIN
    joins('LEFT JOIN product_taggings product_taggings_1 ON product_taggings_1.event_id = events.id LEFT JOIN product_tags product_tags_1 ON product_taggings_1.event_tag_id = product_tags_1.id')
      .where("events.name LIKE :pattern
             OR city LIKE :pattern
             OR location LIKE :pattern
             OR product_tags_1.name LIKE :pattern",
             pattern: "%#{search_term}%")
  }
  scope :start_date, ->(date) { where('start_date >= ?', date) }
  scope :end_date, ->(date) { where('start_date <= ?', date) }
  scope :by_year, ->(date) { start_date(date.beginning_of_year).end_date(date.end_of_year) }
  scope :by_month, ->(date) { start_date(date.beginning_of_month).end_date(date.end_of_month) }
  scope :by_period, ->(date, period) { start_date(date).end_date(date + period.days) }
  scope :search_by_tags, ->(tag_ids) { joins(:product_tags).where(product_tags: { id: tag_ids }) }
  scope :search_by_coaches, ->(coach_id) { joins(:coaches).where(coaches: { id: coach_id }) }
  scope :search_by_type, ->(type_id) { where(eventtype_id: type_id) }
  scope :search_by_eventtemplate_id, ->(eventtemplate_id) { where(eventtemplate_id: eventtemplate_id) }

  # Scopes for creating target_groups
  scope :filter_by_price, ->(price, modifier) { where("events.full_price_cents #{modifier} ?", price) }
  scope :filter_by_location, ->(distance, origin) { within(distance, origin: origin) }

  # class methods
  def to_s
    name
  end

  # get current price for event depending on price, price_early_signup,
  # early_signup_pricing and early_signup_deadline
  def price
    if early_booking_price_applies?
      price_early_signup
    else
      full_price
    end
  end

  def price_cents
    price.cents
  end

  # used for geocoding
  def full_street_address
    address = [street, streetno, city]
    address.join(' ') if address.all?(&:present?)
  end

  def location?
    location.present?
  end

  def participantlist_pdf
    html_options = ['events/pdf/participantlist/participantlist_pdf.html', layout: 'pdf_list.html', locals: { :@title => I18n.t(:participantlist), :@event => self, :@eventbookings => self.eventbookings.confirmed_bookings }]
    generator = ::PdfGenerator.new(html_options, pdf_options)
    generator.footer_html_options = ['events/pdf/participantlist/footer.html', layout: 'pdf_list.html', locals: { :@event => self }]
    generator.header_html_options = ['events/pdf/participantlist/header.html', layout: 'pdf_list.html', locals: { :@event => self, :@pdfname => I18n.t(:participantlist) }]
    generator.rendered_pdf
  end

  def attendancelist_pdf
    html_options = ['events/pdf/attendancelist/attendancelist_pdf.html', layout: 'pdf_list.html', locals: { :@title => I18n.t(:attendancelist), :@event => self, :@eventbookings => self.eventbookings.confirmed_bookings}]
    generator = ::PdfGenerator.new(html_options, pdf_options)
    generator.footer_html_options = ['events/pdf/attendancelist/footer.html', layout: 'pdf_list.html', locals: { :@event => self }]
    generator.header_html_options = ['events/pdf/attendancelist/header.html', layout: 'pdf_list.html', locals: { :@event => self, :@pdfname => I18n.t(:attendancelist) }]
    generator.rendered_pdf
  end

  def self.csv(attributes)
    CSV.generate(headers: false, col_sep: ";", force_quotes: true, encoding:'utf-8') do |csv|
      csv << attributes.map {|attr| I18n.t(attr) }
      all.each do |event|
        csv << attributes.map {|attr| event.send(attr) }
      end
    end
  end

  def self.csv_list
    csv %i(id name eventtype gross_price vat_rate vat_sum net_price price price_early_signup currency start_date start_time end_date end_time duration durationunit allow_signup shortdescription longdescription slug external_signup_url external_signup_text early_signup_pricing onlinestatus planningstatus generate_invoice vat_id latest_signup_date early_signup_deadline eventorganizer location street streetno zip city country googlemapslocation latitude longitude eventtemplate redirect_message max_additional_participants reservation_expiry type show_remaining_seats_count)
  end

  def generate_invoice?
    !free? && generate_invoice
  end

  # integrity test for additional_participants: allowed > 0 only for free events
  # free events: price_cents is 0 and price_early_signup_cents
  def max_additional_participants_for_free_events_only
    if additional_participants? && (!free? or (early_signup_pricing && price_early_signup_cents.present? && price_early_signup_cents.positive?))
      errors.add(:max_additional_participants, I18n.t(:max_additional_participants_only_for_free_events))
    end
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :name,
      %i(name start_date city),
      %i(name start_date city zip),
      %i(name start_date city zip street)
    ]
  end

  def show_free_seats?
    show_remaining_seats_count
  end

  # create eventbooking from order
  def create_eventbooking(order)
    @order = EventbookingService.new.book_event(order)
  end

  def order_allowed?
    true
  end

  def bookable?
    free_seats?
  end

  # true if date is past latest signup date
  def latest_signup_date_exceeded?
    if latest_signup_date.present? and latest_signup_date.to_time < Time.now
      true
    else
      false
    end
  end

  def reservation_expiry
    read_attribute(:reservation_expiry) || start_date&.advance(days: -5) || (Date.today + 7.days)
  end

  # This method can be extended by any derived classes
  def setup; end

  def seats_limited?
    maxparticipants.present?
  end

  def free?
    price.blank? || price.zero?
  end

  # does the event have free seats?
  def free_seats?
    # yes if not booked_up
    !booked_up?
  end

  # is the event fully booked?
  def booked_up?
    seats_limited? && (seats_free <= 0)
  end

  def additional_participants?
    max_additional_participants.present? && max_additional_participants.positive?
  end

  def additional_participants_available
    if additional_participants?
      if max_additional_participants <= seats_free
        max_additional_participants
      else
        max_additional_participants - (max_additional_participants - seats_free) - 1
      end
    else
      0
    end
  end

  def redirect_message
    text = read_attribute(:redirect_message)
    text = I18n.t(:default_redirect_text) if text.blank?
    text
  end

  def cancel
    self.planningstatus = Planningstatus.find_by key: 'cancelled'
    self.allow_signup = false
    self
  end

  def cancelled?
    if planningstatus
      planningstatus.key == 'cancelled'
    else
      false
    end
  end

  def external_signup?
    external_signup_url.present?
  end

  # get the next position
  def getnextnumber
    last_eventsessions = eventsessions
    last_eventsessions.count + 1
  end

  # get the next start day for multi day events
  def getnextstartdate
    last_eventsession = eventsessions.maximum('start_date')
    if last_eventsession.nil?
      start_date
    else
      last_eventsession + 1.day
    end
  end

  # returns the number of bookings for an event
  # def existing_bookings_count_off
  #   #eventbookings.signedup_bookings.count
  #   seats_booked
  # end

  # add available payment methods
  def add_paymentmethods
    paymentmethods << account.paymentmethods
  end

  # def booking_count_off
  #   eventbookings.signedup_bookings.count
  #   #seats_booked
  # end

  # get the number of booked seats for this event
  # i.e. eventbookings with status confirmed waiting + additional_participants
  def seats_booked
    i = eventbookings.signedup_bookings.count
    eventbookings.signedup_bookings.each do |eventbooking|
      i = i + eventbooking.get_additional_participants_count
    end
    return i
  end

  def seats_free
    if !maxparticipants.nil?
      if ((maxparticipants - seats_booked) <= 0)
        0
      else
        maxparticipants - seats_booked
      end
    else
      0
    end
  end

  def get_waiting_list_count
    eventbookings.waiting_list.count
  end

  # return time according to application setting
  def start_time
    # start_date.strftime('%H:%M')
    start_date.in_time_zone(account.get_time_zone).strftime('%H:%M') if start_date.respond_to?(:strftime)
  end

  # return time according to fixed string
  def start_time_with_timezone
    # start_date.in_time_zone('Europe/Berlin').strftime('%H:%M')
    start_date.in_time_zone(account.get_time_zone).strftime('%H:%M') if start_date.respond_to?(:strftime)
  end

  def end_time
    if end_date
      # end_date.strftime('%H:%M')
      end_date.in_time_zone(account.get_time_zone).strftime('%H:%M') if end_date.respond_to?(:strftime)
    else
      nil
    end
  end

  def end_time_with_timezone
    if end_date
      # end_date.in_time_zone('Europe/Berlin').strftime('%H:%M')
      end_date.in_time_zone(account.get_time_zone).strftime('%H:%M') if end_date.respond_to?(:strftime)
    else
      nil
    end
  end

  # does early booking pricing apply?
  def early_booking_price_applies?
    # is early_signup_pricing set up and are we still before the early_signup_deadline?
    early_pricing_activated? && early_signup_deadline >= Time.now
  end

  # duplicate self and return copy
  def duplicate
    return EventDuplicate.new(self).perform
  end

  # return true / false if event is visible online or not
  def online?
    onlinestatus&.key == 'online' && planningstatus&.key == 'planned'
  end

  def scheduled?
    onlinestatus&.key != 'offline' && planningstatus&.key == 'planned'
  end

  # create new event from eventtemplate
  def self.create_from_template(eventtemplate)
    return EventCreateFromEventtemplate.new(eventtemplate).perform
    event
  end

  # slug generation with friendly_id
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
    #|| name_changed?
  end

  # do prices include vat?
  def vat_included?
    self.account.vat_included
  end

  # do we display net prices first?
  def vat_net_first?
    self.account.vat_net_first
  end

  # return the value of vat object assigned to events
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

  # checks if event has multipricing, i.e.:
  # pricingset attached
  # pricingset is active
  # pricingset has one or more active pricingoptions with preset == true
  # and event.type is StandardEvent or IndividualEvent or BundleEvent
  def multipricing?
    if pricingset && pricingset&.active && pricingset&.pricingoptions&.with_preset&.count > 0 && !free?
    #(type == "StandardEvent" || type == "IndividualEvent" || type == "BundleEvent" || type == "OnlineEvent")
      true
    else
      false
    end
  end

  def is_bundle?
    self.is_a?(BundleEvent)
  end

  # get the event contact from event itself (field to be implemented) or from account
  def get_event_contact
    if contact_information.present?
      contact_information
    else
      account.event_contact
    end
  end
  # location methods: prefer product_location relation over event fields

  # location methods from event object
  # location: Der Name des Veranstaltungsortes, z.B. Seminarzentrum Hamburg
  # eventorganizer: Veranstalter, wie z.B. Business Seminare Hamburg GmbH
  # street: Strasse der Adresse
  # streetno: Hausnummer der Adresse
  # zip: PLZ der Adresse
  # city: Stadt der Adresse
  # country: Land der Adresse
  # googlemapslocation: Link auf Google Maps, muss manuell eingefügt werden
  # latitude: Breitengrad der Adresse
  # longitude: Längengrad der Adresse

  # use_product_location: If true, product_location is used instead ov event.* location methods

  # product_location methods
  # eventorganizer_name: Name of the event organizing entitiy, i.e. "Business Seminare Hamburg GmbH"
  # location_name: Name of the location, i.e. Seminarzentrum Hamburg
  # street: Street of the location's address
  # street_no: Street no. of the location's address
  # zip: Zip of the location's address
  # city: City of the location's address
  # state: State of the location's address, i.e. Hamburg, Bayern, California, Utah
  # country: Country of the location's address
  # googlemapslocation: Link to google maps with the location's address
  # latitude: Latitude of the location's address
  # longitude: Longitude of the location's address
  # displayed_address: Address to be displayed when the location's address is displayed, can be edited manually
  # icon_file_name: Icon for google maps of the location's address
  # time_zone: Timezone of the location's address
  # show_time_zone_in_checkout: Dicides if timezone of the location's address is displayed in checkout
  # directions: Directions of the location's address as text information
  # directionspdf_file_name: Dorections of the location's address as PDF download
  # cost_fixed_cents: Fixed cost of the location's address, i.e. cost per booking
  # cost_variable_cents: Variable cost of the location's address, i.e. cost per day, hour..., derived from cost_variable_unit
  # cost_variable_unit: Unit of the variable cost of the location's address, i.e. days, hours

  # methods for attributes from product_locations.
  # these methods retrieve the product_location.* methods if use_product_location is true
  # else they use the location fields from event object

  # true if eventorganizer or location are set in event or location (if location is assigned)
  def has_location?
    get_eventorganizer.present? || get_location.present?
  end

  # getter methods to retrieve location from event or location
  def get_location
    if use_product_location
      product_location&.location_name
    else
      location
    end
  end

  def get_eventorganizer
    if use_product_location
      product_location&.eventorganizer_name
    else
      eventorganizer
    end
  end

  def get_street
    if use_product_location
      product_location&.street
    else
      street
    end
  end

  def get_streetno
    if use_product_location
      product_location&.street_no
    else
      streetno
    end
  end

  def get_city
    if use_product_location
      product_location&.city
    else
      city
    end
  end

  def get_zip
    if use_product_location
      product_location&.zip
    else
      zip
    end
  end

  def get_state
    if use_product_location
      product_location&.state
    else
      state
    end
  end

  def get_latitude
    if use_product_location
      product_location&.latitude
    else
      latitude
    end
  end

  def get_longitude
    if use_product_location
      product_location&.longitude
    else
      longitude
    end
  end

  def get_country
    unless self.new_record?
      if use_product_location
        country_obj = ISO3166::Country[product_location&.country]
      else
        country_obj = ISO3166::Country[country]
      end
      unless country_obj.nil?
        country_obj.translations[I18n.locale.to_s] || country_obj.name
      end
    end
  end

  def get_googlemapslocation
    if use_product_location
      product_location&.googlemapslocation
    else
      googlemapslocation
    end
  end

  def get_full_street_address
    if use_product_location
      product_location&.full_street_address
    else
      full_street_address
    end
  end

  def get_directions
    if use_product_location
      product_location&.directions
    else
      nil
    end
  end

  def has_directions_download?
    if use_product_location && product_location.directionspdf.exists?
      true
    else
      false
    end
  end

  protected

  def set_values
    self.colorcode = '#bbbbbb' if colorcode.blank?
    self.reservation_expiry ||= start_date - 5.days if start_date.present?
    assign_attributes(price_early_signup: nil, early_signup_deadline: nil) unless early_signup_pricing
    #self.geocode
  end

  def update_parent_event
    unless is_bundle?
      bundleevents.each do |bundleevent|
        bundle_event = BundleEventUpdateFromSubevent.new(bundleevent.event, self).perform
      end
    end
  end

  def early_pricing_activated?
    early_signup_pricing.present? && early_signup_deadline.present?
  end

  def pdf_options
    {
      margin: {
        top: '30mm',
        bottom: '20mm'
      }
    }
  end

  def clear_coordinates
    self.latitude = nil
    self.longitude = nil
  end
end
