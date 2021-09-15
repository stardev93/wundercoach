# Implements Bookings via Invoice
class InvoiceBooking < Booking
  def self.model_name
    Booking.model_name
  end

  # use this in cronjob to activate a booking when another one expires
  def activate
    billing_periods.build(start_date: valid_from)
  end
end
