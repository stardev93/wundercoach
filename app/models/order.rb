# Order
# an order represents the contract between a booking and paying entity (a participant or company sending participant(s))
# handles the whole signup process for any product

require "#{Rails.root}/app/services/billing/invoice_create_from_order"
require "#{Rails.root}/app/services/billing/invoice_send"

class Order < ActiveRecord::Base
  class CannotInvoiceError < StandardError; end
  acts_as_tenant(:account)
  include Filterable

  monetize :price_cents, with_model_currency: :currency, allow_nil: true

  ## The states of an order:
  # just started: customer has just started the checkout, without providing any information so far.
  # -> we may lock a seat at this stage
  # address_completed: Customer has successfolly entered all relevant data
  # -> We could create a Customer model with the data.
  # payment_chosen: The customer has chosen payment. Just one more step...
  # confirmed: The customer confirmed the order (and paid if required). He accepted Terms of Service
  # -> We show a thank you page and trigger some business logic
  # waiting_for_payment: Order needs payment before final confirmation (advanced payment only)
  # paid: Confirmed and paid.
  enum status: %i(just_started data_completed payment_chosen confirmed waiting_for_payment paid)

  scope :unconfirmed, -> { where.not(status: Order.states_by_keys(%w(confirmed waiting_for_payment paid))) }
  scope :confirmed, -> { where(status: Order.states_by_keys(%w(confirmed waiting_for_payment paid))) }
  scope :start_date, ->(date) { where('order_date >= ?', date) }
  scope :end_date, ->(date) { where('order_date <= ?', date) }

  has_many :businessdocuments, class_name: 'Billing::Businessdocument', autosave: true, dependent: :nullify, foreign_key: "order_id"
  has_many :businessdocumentpositions, class_name: 'Billing::Businessdocumentposition', autosave: true, dependent: :nullify, foreign_key: "order_id"
  has_many :eventbookings, dependent: :destroy

  belongs_to :address, autosave: true
  belongs_to :billing_address, class_name: 'Address', autosave: true
  belongs_to :user
  belongs_to :paymentmethod
  belongs_to :product, polymorphic: true
  belongs_to :adpartner
  belongs_to :businessdocumentposition, class_name: 'Billing::Businessdocumentposition'

  accepts_nested_attributes_for :businessdocuments, :address, :billing_address

  before_create :set_price_and_idempotency_key

  validates :terms_of_service, acceptance: true
  validates :gdpr_terms, acceptance: true
  validates :revocation_terms, acceptance: true

  delegate :vat, :generate_invoice?, to: :product

  delegate(
    :country, :country_name, :company, :firstname, :lastname, :gender, :email,
    :zip, :city, :telephone, :salutation, :gender_direct, :gender_indirect,
    :street, :fullname, to: :address
  )

  # http://api.rubyonrails.org/classes/ActiveRecord/Store.html
  store :additional_data, accessors: %i(additional_participants), coder: JSON

  # ToDo: this should be in a decorator
  # Is it OK to return the product name? orders and eventbookings are used in the same manner
  def to_s
    I18n.t(:order_for, product: product)
  end

  def free?
    !price&.positive?
  end

  def checkout_finished?
    status.in? %w(confirmed waiting_for_payment paid)
  end

  def full_price
    price
  end

  def businessdocument
    businessdocuments.first
  end

  # hash of objects to substitute
  def to_substitution_hash
    {
      'eventbooking' => self, # TODO: remove this temporary solution
      'order' => self,
      'event' => product,
      'user' => user,
      'businessdocuments' => businessdocuments
    }
  end

  # # call invoice creation service for order
  # def create_invoice
  #   # create an invoice from order object, i.e. with eventbooking attached
  #   return InvoiceCreateFromOrder.new(self).perform
  # end

  # finalize order
  # generate eventbooking
  # assign all values
  # write order to database
  # generate invoice
  def confirm
    # byebug
    assign_attributes({
      order_date: Time.now,
      affiliate_commission_relative: account.affiliate_commission_relative,
      affiliate_commission_absolute: account.affiliate_commission_absolute
    })
    # byebug

    if adpartner.present?
      assign_attributes({
        adpartner_commission_relative: adpartner.affiliate_commission_relative,
        adpartner_commission_absolute: adpartner.affiliate_commission_absolute
      })
    end
    # # save once to see if object validates
    save!
    if paymentmethod.key == 'vorkasse'
      # byebug
      # set status and send booking confirmation for advanced payment
      confirm_advanced_payment
    else
      # set status and send booking confirmation
      confirm_standard_payment
    end

    self.status = :paid if paymentmethod.online_payment?

    # # generate eventbooking
    # byebug
    @eventbooking = product.create_eventbooking(self)

    # send invoice if automatic invoicing is enabled
    if generate_invoice?
      # create invoice object & create pdf
      @invoice = InvoiceCreateFromOrder.new(self, @eventbooking).perform
      InvoiceSend.new(@invoice).perform
    end

    # # save again after invoice generation
    save!

    send_notification! if product.notify?
    update_crm if product.crm_enabled?
  end

  def create_manually!
    assign_attributes({
      order_date: Time.now,
      status: paymentmethod.key == 'vorkasse' ? :waiting_for_payment : :confirmed
    })

    save!
    product.create_eventbooking(self)
  end

  # calls create_invoice
  def generate_invoice
    @invoice = create_invoice
    # @invoice.delay.create_pdf
    InvoiceSend.new(@invoice).perform
  end

  # return billing address if set, else return address
  def invoice_address
    billing_address || address
  end

  def self.states_by_keys(keys)
    Order.statuses.select {|key, _val| keys.include? key }.values
  end

  # upserts a contact in active campaign using the order's data
  def update_crm
    client = account.active_campaign_client
    list_id = account.active_campaign_default_list
    client.contact_sync({
      'email' => email,
      'first_name' => firstname,
      'last_name' => lastname,
      'phone' => telephone,
      'orgname' => company,
      "p[#{list_id}]" => list_id,
      'tags' => product.tags.join(', ')
    })
  end

  def net_affiliate_commission
    affiliate_commission - adpartner_commission
  end

  def affiliate_commission
    @affiliate_commission ||= (price * affiliate_commission_factor + Money.new(affiliate_commission_absolute * 100))
  end

  def adpartner_commission
    @adpartner_commission ||= (affiliate_commission * adpartner_commission_factor + Money.new(adpartner_commission_absolute * 100))
  end

  def net_price
    ProductCalculatePrice.new(price, product.vat, product.vat_included?).net_price
  end

  def gross_price
    ProductCalculatePrice.new(price, product.vat, product.vat_included?).gross_price
  end

  def vat_sum
    ProductCalculatePrice.new(price, product.vat, product.vat_included?).vat_sum
  end

  def vat_rate
    ProductCalculatePrice.new(price, product.vat, product.vat_included?).vat_rate
  end

  # return the pricingoption assigned to the order
  # else return nil
  def get_pricingoption
    Product::Pricingoption.find_by(id: pricingoption) if pricingoption
  end

  def get_first_booking
    return eventbookings.by_id.first
  end

  def is_bundle_order?
    true if get_first_booking&.event&.is_a? BundleEvent
  end

  private

  def adpartner_commission_factor
    adpartner_commission_relative / 100
  end

  def affiliate_commission_factor
    affiliate_commission_relative / 100
  end

  def set_price_and_idempotency_key
    self.idempotency_key = SecureRandom.uuid
    self.price = product.price
  end

  def send_notification!
    request = HTTPI::Request.new(account.notification_url)
    request.headers['Content-type'] = 'application/x-www-form-urlencoded; charset=utf-8'
    request.headers['Accept-Charset'] = 'utf-8'
    request.body = {
      event_type: Rails.env.production? ? 'sale' : 'test',
      email: email,
      product_code: product.digimember_id,
      order_id: id,
      first_name: firstname,
      last_name: lastname
    }
    HTTPI.post(request)
  end

  def send_confirmation_mail(mailtemplate)
    # byebug
    mail_options = { to: address.email }
    mail_options[:bcc] = account.order_mail_recipients if account.order_bcc_list.present?
    EventMailer.send_composed_mail(self.account, self, mailtemplate, mail_options).deliver_later
  end

  # Booking Confirmation for Advanced Payment Bookings (Vorkasse)
  def confirm_advanced_payment
    self.status = :waiting_for_payment
    # byebug
    send_confirmation_mail Mailtemplate.find_by(key: 'booking_confirmation_email_advanced_payment')
  end

  # Booking Confirmation for Standard Payment Bookings. Used for all payment types except advanced payment
  def confirm_standard_payment
    self.status = :confirmed
    if product.is_a? OnlineEvent
      mailtemplate_key = 'booking_confirmation_email_online_event'
    else
      mailtemplate_key = 'booking_confirmation_email'
    end
    send_confirmation_mail Mailtemplate.find_by(key: mailtemplate_key)
  end

end
