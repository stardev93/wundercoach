json.array!(@accountinvoicetypes) do |accountinvoicetype|
  json.extract! accountinvoicetype, :id, :key, :name, :description, :position
  json.url accountinvoicetype_url(accountinvoicetype, format: :json)
end
