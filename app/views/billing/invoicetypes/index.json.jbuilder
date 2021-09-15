json.array!(@invoicetypes) do |invoicetype|
  json.extract! invoicetype, :id, :key, :name, :description, :position
  json.url invoicetype_url(invoicetype, format: :json)
end
