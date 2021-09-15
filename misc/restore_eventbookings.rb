Order.find_each do |order|
  booking = Eventbooking.find_by(booking_date: order.order_date)
  next if booking.nil? || booking.order_id.present?
  booking.assign_attributes({
    order_id: order.id,
    address_id: order.address&.id,
    billing_address_id: order.billing_address&.id
  })
  booking.save(validate: false)
end
