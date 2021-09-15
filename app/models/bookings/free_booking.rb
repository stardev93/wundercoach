# Implements Bookings via Invoice
class FreeBooking < Booking
  def self.model_name
    Booking.model_name
  end

  def billable?
    false
  end
end
