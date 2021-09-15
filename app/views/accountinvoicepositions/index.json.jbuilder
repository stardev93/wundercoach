json.array!(@Accountinvoicepositions) do |accountinvoiceposition|
  json.extract! accountinvoiceposition, :id, :accountinvoice_id, :position, :paymentplan_id, :paymentplan_name, :paymentplan_cycle, :paymentplan_amount, :paymentplan_price
  json.url accountinvoiceposition_url(accountinvoiceposition, format: :json)
end
