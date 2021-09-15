json.array!(@paymentmethods) do |paymentmethod|
  json.extract! paymentmethod, :id, :key, :name, :comment
  json.url paymentmethod_url(paymentmethod, format: :json)
end
