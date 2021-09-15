# Shared behaviour of Event and Eventtemplate
class BaseEvent < ActiveRecord::Base
  # There's no table for this model, it's just used to prevent code duplication
  # between Event and Eventtemplate
  self.abstract_class = true

  include HasCountry

  # Associations
  belongs_to :durationunit
  belongs_to :eventtype
  belongs_to :product_location, class_name: 'Product::Location'

  geocoded_by :full_street_address
  after_validation :geocode, unless: "geocoded? || full_street_address.nil?"
  after_validation :clear_coordinates, if: "geocoded? && full_street_address.nil?"

  # Validations
  validates :name, :eventtype, presence: true
  validates_length_of :name, :slug, maximum: 255
  validates :slug, uniqueness: true
  validates_associated :eventtype
  validates :max_additional_participants, presence: true

  validates_with FriendlyUrlValidator

  nilify_blanks only: %i(digimember_id)

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
  protected

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
