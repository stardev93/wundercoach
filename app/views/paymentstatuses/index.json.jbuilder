json.array!(@paymentstatuses) do |paymentstatus|
  json.extract! paymentstatus, :id, :key, :name, :comment
  json.url paymentstatus_url(paymentstatus, format: :json)
end
