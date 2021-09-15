json.array!(@bookings) do |booking|
  json.extract! booking, :id, :account_id, :name, :comments, :key, :price_m, :price_y, :valid_until, :active, :paymentcycle, :currency
  json.url booking_url(booking, format: :json)
end
