json.array!(@accountpaymentmethods) do |accountpaymentmethod|
  json.extract! accountpaymentmethod, :id, :account_id, :paymentmethod_id
  json.url accountpaymentmethod_url(accountpaymentmethod, format: :json)
end
