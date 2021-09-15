# Basic Booking methods and interface.
# see StripeBooking and InvoiceBooing for concrete implementation
class Booking < ActiveRecord::Base
  acts_as_tenant(:account)

  include BookingAdmin

  belongs_to :account
  belongs_to :paymentplan
  has_many :billing_periods, autosave: true, dependent: :destroy

  belongs_to :predecessor, foreign_key: "predecessor_id", class_name: "Booking"

  scope :history, -> { where("bookings.id < ?", Booking.current.id).order(id: :desc) }
  scope :current, -> { where(is_current: true).last }
  scope :lastbooking, -> { order(id: :asc).last }

  # Hide Bookings of soft-deleted Accounts
  scope :has_undeleted_account, -> { joins(:account).where(accounts: { deleted_at: nil }) }

  # Finds bookings that are still marked as current, but no longer valid
  # e.g. bookings that have to be replaced with another booking
  scope :recently_expired, lambda {
    has_undeleted_account
      .where(is_current: true)
      .where("valid_until < ?", Date.today)
  }

  # Booking is a TrialBooking, TrialBooking ends in 5 days from now, and 1. mail hasn't been sent before (trial_expiry_reminder_one_sent is null)
  scope :trial_booking_reminder_one, lambda {
    has_undeleted_account
      .where(is_current: true)
      .expired_at(Date.today + 5.days)
      .where(type: "TrialBooking", trial_expiry_reminder_one_sent: nil)
  }

  # Booking is a TrialBooking, TrialBooking ends in 1 day from now, and 2. mail hasn't been sent before (trial_expiry_reminder_two_sent is null), and 1. email has been sent
  scope :trial_booking_reminder_two, lambda {
    has_undeleted_account
      .where(is_current: true)
      .expired_at(Date.tomorrow)
      .where(type: "TrialBooking", trial_expiry_reminder_two_sent: nil)
      .where.not(trial_expiry_reminder_one_sent: nil)
  }

  scope :paid, -> { joins(:paymentplan).where(is_current: true).where("paymentplans.price > 0").where.not(bookings: { type: %w(FreeBooking TrialBooking) }) }

  # send reminder email to FreeBooking-Users that where downgraded from a TrialBooking Plan
  # challenge: we have to join two records: currentFreeBooking and previous TrialBooking
  # Criteria:
  # Currentbooking is valid_from today or earlier, trial_expired_one is nil (i.e. email has not been sent), type is 'FreeBooking'
  # and predecessor has type='TrialBooking', valid_until < Date.today
  scope :trial_expired_one, lambda {
    joins(:predecessor)
      .where("predecessors_bookings.type='TrialBooking'")
      .where("predecessors_bookings.valid_until < ?", Date.today)
      .where("bookings.valid_from <= ?", Date.today)
      .where("bookings.type='FreeBooking'")
      .where("bookings.trial_expired_one_sent IS NULL")
  }

  # send reminder email to FreeBooking-Users that where downgraded from a TrialBooking Plan after 5 days
  # challenge: we have to join two records: currentFreeBooking and previous TrialBooking
  # Criteria:
  # Currentbooking is valid_from 5 days ago or earlier, trial_expired_one is nil (i.e. email has not been sent), type is 'FreeBooking'
  # and predecessor has type='TrialBooking', valid_until < Date.today
  scope :trial_expired_two, lambda {
    joins(:predecessor)
      .where("predecessors_bookings.type='TrialBooking'")
      .where("predecessors_bookings.valid_until < ?", Date.today)
      .where("bookings.valid_from <= ?", Date.today - 5.days)
      .where("bookings.type='FreeBooking'")
      .where("bookings.trial_expired_one_sent IS NOT NULL")
      .where("bookings.trial_expired_two_sent IS NULL")
  }

  scope :expired_at, ->(date) { where("valid_until <= ?", date) }

  delegate :free?, :name, :cycle, :cycle_in_days, to: :paymentplan

  def to_s
    name
  end

  # can we charge something for this booking? default: true
  def billable?
    true
  end

  def price
    paymentplan.gross_price_cents
  end

  def trial?
    false
  end

  # send trial expiry reminder 5 days before expiry
  # set trial_expiry_reminder_one_sent to Date.today
  def send_trial_expiry_reminder_one
    BookingMailer.send_expiry_reminder_one(self).deliver_later
    # set date so email doesn't get send again
    self.trial_expiry_reminder_one_sent = Date.today
    save!
  end

  # send trial expiry reminder 1 day before expiry
  # set trial_expiry_reminder_two_sent to Date.today
  def send_trial_expiry_reminder_two
    BookingMailer.send_expiry_reminder_two(self).deliver_later
    # set date so email doesn't get send again
    self.trial_expiry_reminder_two_sent = Date.today
    save!
  end

  # send trial expired one
  # same day the trial expired
  def send_trial_expired_one
    BookingMailer.send_trial_expired_one(self).deliver_later
    self.trial_expired_one_sent = Date.today
    save!
  end

  # send trial expired 5 days after expiry
  def send_trial_expired_two
    BookingMailer.send_trial_expired_two(self).deliver_later
    self.trial_expired_two_sent = Date.today
    save!
  end

  def current_billing_period
    billing_periods.current.last
  end

  # Determines when the current billing period will end
  # Classes that don't have a billing period must override this method
  def end_of_period
    current_billing_period.end_date
  end

  # checks if the booking is expired
  def expired?
    # if a booking is not the current booking, it is already is expired
    # if the current_booking is expired, this indicates that the next booking should become the current booking
    if is_current
      valid_until.present? && valid_until < Date.today
    else
      true
    end
  end

  # disables this booking and activates the most recent booking
  # creates a free booking if there is no recent booking
  # run by a cronjob after midnight
  def expire!
    # set tenant explicitly, since this may be used in a job where the tenant is not yet set
    ActsAsTenant.with_tenant(account) do
      new_billing_period = nil
      self.is_current = false
      successor = Booking.last
      if id == successor.id
        # create a free booking if there is no succeeding booking
        successor = FreeBooking.new paymentplan: Paymentplan.default_plan
      elsif successor.billable?
        # create the first billing period for the succeeding booking
        new_billing_period = BillingPeriod.new booking: successor,
                                               start_date: Date.today
        successor.billing_periods << new_billing_period
      end
      successor.assign_attributes is_current: true, valid_from: Date.today, predecessor: self
      ActiveRecord::Base.transaction do
        new_billing_period.delay.charge! if new_billing_period
        successor.save!
        save!
      end
    end
  end

  # return the remaining days in current booking
  # until booking is renewed or ends
  def remaining_days
    [0, (valid_until - Date.today).to_i].max if valid_until.present?
  end

  # return the total days in current booking
  # until booking is renewed or ends
  def total_days
    (valid_until - created_at.to_date).to_i if valid_until.present?
  end

  # Decides if the transition should be an upgrade by comparing the booking's paymentplans
  def upgrade?(previous_booking)
    paymentplan > previous_booking.paymentplan && !previous_booking.trial?
  end

  # replaces booking via upgrade or downgrade
  # this is used for booking plans manually
  def succeed_booking!(previous_booking)
    ActiveRecord::Base.transaction do
      if upgrade?(previous_booking)
        upgrade!(previous_booking)
      else
        downgrade!(previous_booking)
      end
    end
  end

  protected

  # transition to higher plan, invoice immediately, change plan immediately
  # always used when changing from FreeBooking to something else
  def upgrade!(previous_booking)
    new_billing_period = BillingPeriod.new booking: self,
                                           start_date: Date.today
    # check if there is a current billing period, and cancel it
    current_billing_period = previous_booking.current_billing_period
    if current_billing_period
      current_billing_period.update!(cancel_date: Date.today)
      new_billing_period.price = price - current_billing_period.cancel_refund
    end

    previous_booking.is_current = false
    assign_attributes({
      is_current: true,
      valid_from: Date.today
    })

    billing_periods << new_billing_period
    previous_booking.save!
    save!
    # run the actual charging in background process, so we can repeat on failure
    new_billing_period.delay.charge!
  end

  # transition to lower plan. Current Booking is cancelled, but active until expiry
  # also used when booking while in trail mode
  def downgrade!(previous_booking)
    previous_booking.valid_until = previous_booking.end_of_period
    self.valid_from = previous_booking.end_of_period + 1.days
    previous_booking.save!
    save!
  end
end
