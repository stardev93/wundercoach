json.array!(@onlinestatuses) do |onlinestatus|
  json.extract! onlinestatus, :id, :key, :name, :description, :position
  json.url onlinestatus_url(onlinestatus, format: :json)
end
