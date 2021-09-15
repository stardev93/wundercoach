json.array!(@invoicestatuses) do |invoicestatus|
  json.extract! invoicestatus, :id, :key, :name, :description, :position, :color, :icon
  json.url invoicestatus_url(invoicestatus, format: :json)
end
