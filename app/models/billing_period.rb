class BillingPeriod < ActiveRecord::Base
  acts_as_tenant(:account)

  belongs_to :booking
  belongs_to :account
  has_many :accountinvoicepositions
  belongs_to :accountinvoice

  before_create :setup

  default_scope -> { order('billing_periods.id DESC') }
  scope :current, -> { where("start_date <= ?", Date.today).where("end_date >= ?", Date.today) }
  # scope :accountinvoice, -> { joins(:accountinvoicepositions).joins(:accountinvoices).where(accountinvoices: { invoicetype_id: '1' }) }

  delegate :paymentplan, to: :booking
  delegate :payment_adapter, to: :account

  def to_s
    "#{booking} #{start_date} - #{real_end_date}"
  end

  # charges this billing period
  def charge!
    assign_attributes payment_adapter.charge!(price, identifier)
    self.paymentdate = Date.today
    begin
      save!
      invoice!
    rescue
      # Don't allow Exceptions here
      Rails.logger.info "Could not create invoice for #{identifier}"
    end
  end

  def invoice!
    Accountinvoice.new.create_new(self, "invoice", "new").delay.create_and_send_pdf
  end

  def expired?(date = Date.today)
    end_date < date
  end

  # creates a new BillingPeriod and charges it immediately
  def expire!
    successor = BillingPeriod.create! booking: booking,
                                      start_date: start_of_next_period
    successor.delay.charge!
  end

  def real_end_date
    cancel_date || end_date
  end

  def start_of_next_period
    end_date + 1.days
  end

  # returns what is refunded if the billing period is cancelled
  # cancelling is only possible for upgrades
  def cancel_refund
    price - price * cancel_factor
  end

  private

  def setup
    self.start_date ||= Date.today
    # Correction (added -1): end days need booking.cycle_in_days - 1 instead booking.cycle_in_days
    # otherwise they will be too long
    self.end_date   ||= start_date + booking.cycle_in_days - 1
    self.price      ||= booking.price
    self.identifier = SecureRandom.uuid # used as idempotency key
  end

  def cancel_factor
    (cancel_date - start_date) / (end_date - start_date)
  end
end
