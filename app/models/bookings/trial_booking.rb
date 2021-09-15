# Implements Trial Bookings
class TrialBooking < Booking
  before_create -> { self.valid_until = 1.months.from_now }

  def to_s
    "#{name} (#{I18n.t(:trial_booking)})"
  end

  def self.model_name
    Booking.model_name
  end

  def trial?
    true
  end

  def billable?
    false
  end

  def end_of_period
    valid_until
  end
end
