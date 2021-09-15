# Eventbooking:
# participation of a single person in an event
# belongs to an order object
class Eventbooking < ActiveRecord::Base
  acts_as_tenant(:account)
  require 'csv'

  include HasCountry
  include Filterable

  before_destroy :protect_official_eventbookings

  # Associations
  belongs_to :event
  belongs_to :eventbookingstatus
  belongs_to :address, autosave: true
  belongs_to :billing_address, class_name: "Address", autosave: true
  belongs_to :order
  belongs_to :contact, class_name: "Crm::Contact"
  has_many :businessdocumentpositions, class_name: "Billing::Businessdocumentposition", dependent: :nullify

  #has_many :businessdocuments, , through: :order
  #has_many :businessdocuments, foreign_key: :order_id, class_name: "Billing::Businessdocument", dependent: :nullify, through: :order
  accepts_nested_attributes_for :address, :billing_address, :order

  has_and_belongs_to_many :campaigns

  # http://api.rubyonrails.org/classes/ActiveRecord/Store.html
  store :additional_data, accessors: %i(additional_participants), coder: JSON

  # Validations

  validates :account, :event, :eventbookingstatus, presence: true
  validates :address, presence: true, on: :update
  validates :terms_of_service, acceptance: true # this only applies for signup
  validate :event_has_free_seats?, on: :create

  # Scopes
  # default scopes are deadly.Do NOT use them
  # default_scope { order("eventbookings.booking_date DESC") }

  scope :new_bookings, -> { joins(:eventbookingstatus).where("eventbookingstatuses.key = 'new'") }
  scope :signedup_bookings, -> { joins(:eventbookingstatus).where(eventbookingstatuses: { key: %w(confirmed waiting) }) }
  scope :confirmed_bookings, -> { joins(:eventbookingstatus).where("eventbookingstatuses.key = 'confirmed'") }
  scope :cancelled_bookings, -> { joins(:eventbookingstatus).where("eventbookingstatuses.key = 'cancelled'") }
  scope :waiting_bookings, -> { joins(:eventbookingstatus).where("eventbookingstatuses.key = 'waiting'") }
  scope :no_bundles, -> { joins(:event).where("events.type != 'BundleEvent'") }
  scope :by_id, -> { joins(:event).order("eventbookings.id ASC") }

  # We have some eventbookings with status new, which are just incomplete eventbookings
  # We will probably not have this kind of eventbooking in the future
  # This scope basically hides these legacy eventbookings
  scope :completed, -> { joins(:eventbookingstatus).where.not(eventbookingstatuses: { key: 'new' }) }

  scope :by_date_desc, -> { order("booking_date DESC") }
  scope :bookings, -> { joins(:eventbookingstatus).order("eventbookingstatuses.position, booking_date") }
  scope :waiting_list, -> { joins(:eventbookingstatus).where("eventbookingstatuses.key = 'waitinglist'") }
  scope :search, lambda {|search_term|
    where('addresses.lastname LIKE :pattern OR
           addresses.firstname LIKE :pattern OR
           addresses.email LIKE :pattern OR
           addresses.company LIKE :pattern OR
           events.name LIKE :pattern OR
           events.city LIKE :pattern OR
           events.location LIKE :pattern',
          pattern: "%#{search_term}%")
  }

  scope :start_date, ->(date) { where("booking_date >= ?", date) }
  scope :end_date, ->(date) { where("booking_date <= ?", date) }
  scope :by_status, ->(status_ids) { where("eventbookingstatus_id IN (?)", status_ids) }

  # CRM
  scope :subscribed, -> {} # { where(crm_status: "subscribed") }
  scope :recently_updated, ->(timestamp) { where("eventbookings.updated_at > ?", timestamp) }

  # Scopes for filtering
  scope :filter_by_price, ->(price, modifier) { joins(:event).where("events.full_price_cents #{modifier} ?", price) }
  scope :filter_by_location, ->(distance, origin) { where(event_id: Event.within(distance, origin: origin).pluck(:id)) }
  scope :filter_by_eventtype, ->(eventtype_id) { joins(event: :eventtype).where(eventtypes: { id: eventtype_id }) }
  scope :filter_by_campaign, ->(campaign_id) { joins(:campaigns).where(campaigns: { id: campaign_id }) }

  delegate :full_price, :currency, :currency_unit, :generate_invoice, to: :event
  delegate :price, to: :order

  delegate(
    :country, :country_name, :company, :firstname, :lastname, :gender, :email,
    :zip, :city, :telephone, :salutation, :gender_direct, :gender_indirect,
    :street, :fullname, to: :address
  )
  delegate :businessdocument, to: :order

  def to_s
    "#{lastname}, #{firstname}"
  end

  def status_is?(status)
    eventbookingstatus.key == status
  end

  # return array of objects that relate to this object for replacing placeholders
  # this method is used by the placeholder substitution algorithm
  def to_substitution_hash
    {
      'eventbooking' => self,
      'event' => event,
      'invoice' => businessdocument,
      'businessdocument' => businessdocument
    }
  end

  # checks if object can be destroyed
  def destroyable?
    %w(new cancelled waitinglist).include? eventbookingstatus.key
  end

  # checks if object can be destroyed
  def cancelable?
    eventbookingstatus.key != 'cancelled'
  end

  def self.csv(attributes)
    CSV.generate(headers: false, col_sep: ";", force_quotes: true, encoding:'utf-8') do |csv|
      csv << attributes.map {|attr| I18n.t(attr) }
      all.each do |eventbooking|
        # csv << attributes.map {|attr| eventbooking.send(attr) }
        csv << [
          eventbooking.id,
          eventbooking.event,
          eventbooking.event.decorate.start_date,
          eventbooking.event.decorate.start_time,
          eventbooking.event.decorate.end_date,
          eventbooking.event.decorate.end_time,
          eventbooking.lastname,
          eventbooking.firstname,
          I18n.t(:"#{eventbooking.gender}_indirect"),
          eventbooking.telephone,
          eventbooking.email,
          eventbooking.company,
          eventbooking.street,
          eventbooking.zip,
          eventbooking.city,
          eventbooking.country,
          eventbooking.created_at,
          eventbooking.booking_date,
          eventbooking.price,
          eventbooking.currency,
          eventbooking.eventbookingstatus,
          eventbooking.event.decorate.get_location,
          eventbooking.event.decorate.get_eventorganizer,
          eventbooking.event.decorate.get_street,
          eventbooking.event.decorate.get_streetno,
          eventbooking.event.decorate.get_zip,
          eventbooking.event.decorate.get_city,
          eventbooking.event.decorate.get_state,
          eventbooking.event.decorate.get_country,
          eventbooking.event.decorate.get_googlemapslocation

        ]
      end
    end
  end

  def self.csv_full
    csv %i(id event start_date start_time end_date end_time lastname firstname gender telephone email company street zip city country created_at booking_date price currency eventbookingstatus location eventorganizer street streetno zip city state country googlemapslocation)
  end

  def self.csv_email
    csv %i(lastname firstname email eventbookingstatus)
  end


  # call invoice creation service for a partial order for a single eventbooking from order.eventbookings
  def create_partial_invoice
    # create a partial invoice from order object, i.e. with eventbooking (self) attached
    return InvoiceCreateFromOrderPartial.new(self.order, self).perform
  end

  # call invoice creation service for order
  def create_invoice
    # create an invoice from order object, i.e. with eventbooking attached
    return InvoiceCreateFromOrder.new(self.order, self).perform
  end

  # count additionl participants, leave out empty values
  def get_additional_participants_count
    i = 0
    if additional_participants.present?
      additional_participants.each_value do |participant|
        if participant[:firstname] != '' && participant[:lastname] != ''
          i = i + 1
        end
      end
    end
    return i
  end

  # returns true if the attached event is part of a bundle booking an can be invoiced with partial invoice
  # partial invoice is an invoice for one eventbooking in a bundle of eventbookings all belonging to
  # the same order
  def partial_invoicing?
    # do we have an eventbooking for a BundleEvent
    if order.product.class == BundleEvent
      # and does self belong to a BundleEvent
      if event.class == BundleEvent
        # full invoice for bundle event
        false
      # or to a Subevent
      else
        # allow partial invoice for subevent of bundle booking
        true
      end
    # or any other type of Event
    else
      false
    end

  end

  private

  def send_confirmation_mail(mailtemplate)
    EventMailer.send_composed_mail(self.account, self, mailtemplate, to: address.email).deliver_later
  end

  def confirm_advanced_payment
    self.eventbookingstatus = Eventbookingstatus.find_by key: 'waiting'
    send_confirmation_mail Mailtemplate.find_by(key: 'booking_confirmation_email_advanced_payment')
  end

  def confirm_standard_payment
    self.eventbookingstatus = Eventbookingstatus.find_by key: 'confirmed'
    send_confirmation_mail Mailtemplate.find_by(key: 'booking_confirmation_email')
  end

  def invoice_address
    billing_address || address
  end

  def event_has_free_seats?
    errors.add(:base, 'This event is booked up.') unless event.free_seats?
  end

  # Used as before_destroy hook
  # if this eventbooking is official:
  # - prevents this eventbooking from being destroyed by returning false
  # - prevents its associated event from being destroyed
  def protect_official_eventbookings
    return true if destroyable?
    raise ActiveRecord::RecordNotDestroyed, I18n.t(:bookings_with_status_confirmed_and_waiting_cannot_be_deleted)
  end

  # class method for generating pdf booking list
  def self.bookinglist_pdf(eventbookings)
    html_options = ['eventbookings/pdf/pdf.html', layout: 'pdf_list.html', locals: { :@title => I18n.t(:bookinglist), :@eventbookings => eventbookings }]
    generator = ::PdfGenerator.new(html_options, self.pdf_options)
    generator.footer_html_options = ['eventbookings/pdf/footer.html', layout: 'pdf_list.html', locals: { :@eventbookings => eventbookings }]
    generator.header_html_options = ['eventbookings/pdf/header.html', layout: 'pdf_list.html', locals: { :@eventbookings => eventbookings }]
    generator.rendered_pdf
  end


  def delete
    if order
      order.businessdocuments.each do |businessdocument|
        businessdocument.order = nil
        if businessdocument.address
          new_address = businessdocument.address.dup
          businessdocument.address.destroy!
          businessdocument.address = new_address
        end
        businessdocument.save!
      end
      order.destroy!
    end
  end

  protected

  def self.pdf_options
    {
      margin: {
        top: '30mm',
        bottom: '30mm',
        left: '20mm',
        right: '20mm'
      }
    }
  end
end
