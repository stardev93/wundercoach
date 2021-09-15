# Implements Bookings via Stripe
class StripeBooking < Booking
  # required by url_helpers
  def self.model_name
    Booking.model_name
  end
end
