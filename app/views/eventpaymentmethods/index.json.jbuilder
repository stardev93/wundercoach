json.array!(@eventpaymentmethods) do |eventpaymentmethod|
  json.extract! eventpaymentmethod, :id, :event_id, :paymentmethod_id
  json.url eventpaymentmethod_url(eventpaymentmethod, format: :json)
end
