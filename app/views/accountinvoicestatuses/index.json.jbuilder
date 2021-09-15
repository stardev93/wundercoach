json.array!(@accountinvoicestatuses) do |accountinvoicestatus|
  json.extract! accountinvoicestatus, :id, :key, :name, :description, :position
  json.url accountinvoicestatus_url(accountinvoicestatus, format: :json)
end
