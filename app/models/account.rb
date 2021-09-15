# Implements multi tenancy.
# Everything you manage within Wundercoach is associated to an account
class Account < ApplicationRecord
  acts_as_paranoid
  include HasCountry
  include AccountAdmin

  nilify_blanks only: %i(name notification_url order_bcc_list checkout_title favicon)

  attr_accessor :from_date, :to_date

  before_validation :prepend_http_to_terms_link, if: :terms_link

  before_save :prepend_staging_to_subdomain, if: 'ENV["RAILS_ENV"]=="staging"'
  before_validation :deactivate_tracking_code

  # Associations
  # Please note that the order of these associations matters when deleting an account
  # e.g. eventbookings must preceed events so they are deleted first,
  # otherwise foreign keys will prevent deleting.
  belongs_to :affiliate
  # TODO: remove unused paymentplan reference
  belongs_to :paymentplan_offer, class_name: 'Paymentplan'
  belongs_to :accountstatus
  belongs_to :accounttype
  # payment_adapter is used for charging the account
  # payment_adapters are the available adapters
  belongs_to :payment_adapter
  belongs_to :default_vat, class_name: 'Vat'
  has_many :accountinvoices, dependent: :nullify # don't delete invoices, they may have pfds attached
  has_many :payment_adapters, autosave: true, dependent: :destroy
  has_many :users, dependent: :destroy
  # We call the first user the creator, since it's created on registration
  has_one :creator, -> { reorder(:id) }, class_name: 'User'
  has_many :eventpaymentmethods, dependent: :delete_all
  has_many :eventbookings, dependent: :delete_all
  has_many :events, dependent: :delete_all
  has_many :bundles, dependent: :delete_all, class_name: 'BundleEvent'
  has_many :individual_events, dependent: :delete_all, class_name: 'IndividualEvent'
  has_many :bookings, dependent: :delete_all, autosave: true
  has_many :mailtemplates, dependent: :delete_all, autosave: true
  has_many :mailskins, dependent: :delete_all, autosave: true
  has_many :invoicepositions, dependent: :delete_all
  has_many :invoicepositions, foreign_key: :account_id, class_name: "Billing::Invoiceposition", dependent: :nullify # don't delete invoices, they may have pfds attached
  has_many :businessdocuments, foreign_key: :account_id, class_name: "Billing::Businessdocument", dependent: :nullify # don't delete invoices, they may have pfds attached
  has_many :accountpaymentmethods, dependent: :delete_all, autosave: true
  has_many :paymentmethods, through: :accountpaymentmethods
  has_many :eventtemplates, dependent: :delete_all
  has_many :eventtypes, dependent: :delete_all, autosave: true
  has_many :features, through: :paymentplan
  has_many :coaches, dependent: :delete_all
  has_many :tools, dependent: :delete_all
  has_many :billing_periods, dependent: :delete_all
  has_many :widgets, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_and_belongs_to_many :vat_countries, dependent: :destroy
  has_many :country_based_vats, through: :vat_countries, source: 'vats', class_name: 'Vat'
  has_many :custom_vats, class_name: 'Vat'
  has_many :smtpservers, dependent: :destroy

  # Marketing
  has_one :mailchimp, autosave: true, dependent: :destroy
  has_many :filters, dependent: :delete_all
  has_many :target_groups, dependent: :delete_all
  has_many :campaigns, dependent: :delete_all

  # TODO: Move this validation into a form object, so we can remove the
  # check_billing_data validation flag
  BILLING_DATA = %i(name city country street streetno zip email_billing_address).freeze
  validates(*BILLING_DATA, presence: true, on: :update, if: :check_billing_data)

  FISCAL_YEAR_START_DAYS = [ "contact_customer", "contact_lead", "contact_partner", "contact_supplier"]
  FISCAL_YEAR_START_MONTHS = [ "contact_customer", "contact_lead", "contact_partner", "contact_supplier"]

  validates :token, uniqueness: true
  validates :order_bcc_list, cc_list: true, if: 'order_bcc_list.present? && order_bcc_list_changed?'
  validates_length_of :name, :name_addon, :checkout_title, :invoice_from_small, maximum: 255

  validates :subdomain, presence: true, exclusion: { in: %W(#{EXTERNAL_SUBDOMAIN} www staging live) }, length: { in: 1..63 }, on: :update
  validates :subdomain, uniqueness: true
  validates_format_of :subdomain,
                      with: /\A[a-z\d]+(-[a-z\d]+)*\z/i,
                      message: I18n.t('activerecord.errors.models.account.attributes.subdomain.format'),
                      multiline: true,
                      on: :update,
                      if: 'changes[:subdomain]'

  has_attached_file :logo, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  has_attached_file :eventheader, styles: { thumb: '600x100>' }, default_url: 'signup-header-default.png'
  has_attached_file :invoicelogo, styles: { thumb: '400x100>' }, default_url: '/images/:style/missing.png'
  has_attached_file :invoicefooter, styles: { thumb: '400x100>' }, default_url: '/images/:style/missing.png'
  has_attached_file :favicon, styles: { icon: ['32x32#', :png], touch_icon: ['180x180#', :png] }, default_url: 'favicon.ico'
  validates_attachment_content_type :logo, :eventheader, :invoicelogo, :invoicefooter, :favicon, content_type: /\Aimage\/.*\Z/

  before_update :normalize_order_bcc_list, if: 'order_bcc_list.present? && order_bcc_list_changed?'

  # http://api.rubyonrails.org/classes/ActiveRecord/Store.html
  store :misc, accessors: %i(show_get_started_modal), coder: JSON

  TRACKING_CODE_LOCATION_HASH = { "tracking_code_header_start" => "tracking_code_header_start", "tracking_code_header_end" => "tracking_code_header_end", "tracking_code_body_start" => "tracking_code_body_start", "tracking_code_body_end" => "tracking_code_body_end" }.freeze

  def to_s
    name || email || I18n.t(:no_accountname_given)
  end

  def default_currency
    Money::Currency.find(default_currency_iso_code)
  end

  def vats
    (country_based_vats + custom_vats).push(Vat.find_by(vat_country: nil, account: nil)).uniq
  end

  def custom_checkout_title
    checkout_title || checkout_title_fallback
  end

  # fallback if checkout_title is not set or account may not use custom title
  def checkout_title_fallback
    "#{name || 'Wundercoach'} | #{I18n.t(:event_management)}"
  end

  # accessors for validation
  attr_accessor :check_billing_data, :delete_confirmation, :terms_of_service

  # bcc list as array
  def order_mail_recipients
    order_bcc_list.split(',').map {|address| address.chomp.strip }.select(&:present?)
  end

  # executes a soft_delete (if possible). replacement for delete/destroy
  def deactivate
    raise ActiveRecord::RecordNotDestroyed.new('cannot_delete_upcoming_events', self) if events.joins(:eventbookings).future_events.any?
    update!(deleted_at: Time.now)
  end

  # provides an ActiveCampaign Client specific for this account
  def active_campaign_client
    @active_campaign_client = ::ActiveCampaign::Client.new({
      api_key: active_campaign_api_key,
      api_endpoint: (active_campaign_api_endpoint + '/admin/api.php')
    })
  end

  def active_campaign_integrated?
    [active_campaign_api_endpoint, active_campaign_api_key].all?(&:present?)
  end

  def sofort_integrated?
    [sofort_user_id, sofort_project_id, sofort_api_key].all?(&:present?)
  end

  def gocardless_integrated?
    gocardless_access_token.present? && gocardless_organisation_id.present?
  end

  def stripe_integrated?
    stripe_access_token.present?
  end

  def paypal_integrated?
    paypal_client_id.present?
  end

  # TODO: Move this to a helper or decorator
  def greeting
    if lastname.present? && firstname.present?
      "#{firstname} #{lastname}"
    elsif email.present?
      email
    elsif name.present?
      name
    else
      accountnumber
    end
  end

  # checks presence of mailchimp api key
  def mailchimp_integrated?
    mailchimp.present?
  end

  # TODO: Move this into a Chart facade
  ##
  # Counts events per period
  # Input:
  # [start_date] where to begin collecting data
  # [period] length of the period, e.g. 1 for weekly event count
  # [record_count] how many periods you want to show
  def event_count_by_period(start_date, period, record_count)
    result = []
    record_count.times do |i|
      result << [i + 1, events.by_period(start_date + i * period, period).count]
    end
    result
  end

  # check if account has all required fields. Used for validation, wundercoach shows an alert as long as this returns false
  def complete?
    BILLING_DATA.all? {|attribute| read_attribute(attribute).present? }
  end

  def accountnumber
    id + 9_999
  end

  # make sure subdomains are always lower case
  # Capital letters in subdomains will cause infinite redirects
  def subdomain=(new_subdmain)
    write_attribute(:subdomain, new_subdmain.strip.downcase)
  end

  def paymentplan
    bookings.current.paymentplan
  end

  # returns if account billing data is complete
  def billing_data_completed?
    [name, zip, street, streetno, city, country, email_billing_address].all?(&:present?)
  end

  def invoicedesign_done?
    [invoice_from, invoice_from_small, invoice_footer].all?(&:present?)
  end

  def mailchimp_contact_data
    {
      company: name,
      address1: "#{street} #{streetno}",
      address2: '',
      city: city,
      state: '',
      zip: zip,
      country: country,
      phone: tel1
    }
  end

  # get the current bookings name
  def current_booking
    bookings.current
  end

  # is the account on a trial booking?
  def trial?
    bookings.current.trial?
  end

  # TODO: Move this into a country value object
  # do we have a customer in germany
  def is_de?
    ISO3166::Country[country.upcase].alpha2 == 'DE'
  end

  # TODO: Move this into a country value object
  # do we have a eu country / but not germany?
  def is_eu_ext?
    c = ISO3166::Country[country.upcase]
    c.in_eu? && c.alpha2 != 'DE'
  end

  def invoice_no_start
    read_attribute(:invoice_no_start) || 10_000
  end

  def cancellation_no_start
    read_attribute(:cancellation_no_start) || 20_000
  end

  def quote_no_start
    read_attribute(:quote_no_start) || 50_000
  end

  def order_no_start
    read_attribute(:order_no_start) || 40_000
  end

  def order_confirmation_no_start
    read_attribute(:order_confirmation_no_start) || 30_000
  end

  # TODO: Move this to a decorator
  def event_contact
    contact = read_attribute(:event_contact)
    if contact.present?
      contact
    else
      email
    end
  end

  # TODO: Move this to a decorator
  def days_since_last_seen
    if last_activity_at
      (Date.today - last_activity_at.to_date).to_i
    else
      '--'
    end
  end

  def show_signup_search?
    show_signup_search
  end

  # return the activated smtpserver
  # if it doesn't exist, return smtpserver with key wundercoach_standard
  def get_smtp_server
    smtpservers.activated.all.first
    # @smtpserver = self.smtpservers.activated.all.first
    # if @smtpserver.blank?
    #   return self.smtpservers.find_by key: "wundercoach_standard"
    # else
    #   return @smtpserver
    # end
  end

  # return payment adapter of type StripePaymentAdapter or GocardlessPaymentAdapter
  def get_payment_adapter(type)
    payment_adapters.find_by(type: type)
  end

  # check if we have an active payment adapter of type
  def payment_adapter_is_active(type)
    payment_adapter = payment_adapters.find_by(type: type)
    # check if payment_adapter is assigned to account.payment_adapter_id
    payment_adapter.id if payment_adapter.id == payment_adapter_id
  end

  # get the active payment adapter, else false
  def get_active_payment_adapter
    payment_adapter unless payment_adapter_id.blank?
  end

  def payment_adapter_allow_delete(pa)
    if pa.id == self.payment_adapter.id
      false
    else
      true
    end
  end

  def registration_date
    return created_at
  end

  def get_time_zone
    if self.time_zone != ''
      self.time_zone
    elsif Rails.configuration.time_zone != ''
      Rails.configuration.time_zone
    else
      'UTC'
    end
  end

  # check if any of the terms fields are required in order to disable button in checkout
  def any_terms_required?
    return terms_required || gdpr_required || revocation_required
  end

  def has_vat_revenue_accounts
    retval = false
    if self.default_vat
      retval = true if self.default_vat.vat_revenue_accounts.exists?
    end
    retval
  end

  # get the (google or whatever) tracking-code in account settings.
  # for the approp. location, see TRACKING_CODE_LOCATION_HASH
  def get_tracking_code(location)
    tracking_code if tracking_code_active && !tracking_code.blank? && tracking_code_location == location
  end

  private

  def destroy
    raise 'Please use deactivate for soft delete, and really_destroy! for hard delete'
  end

  def normalize_order_bcc_list
    self.order_bcc_list = order_mail_recipients.join(', ')
  end

  def prepend_staging_to_subdomain
    if %w(staging).include?(ENV['RAILS_ENV']) && subdomain.present?
      self.subdomain = subdomain.split('.').first + '.staging'
    end
  end

  def prepend_http_to_terms_link
    self.terms_link = "http://#{terms_link}" unless terms_link =~ /^https?:\/\//
  end

  def deactivate_tracking_code
    if self.tracking_code.blank?
      self.tracking_code_active = false
    end
    true
  end

end
