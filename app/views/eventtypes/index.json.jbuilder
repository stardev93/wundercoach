json.array!(@eventtypes) do |eventtype|
  json.extract! eventtype, :id, :key, :name, :description
  json.url eventtype_url(eventtype, format: :json)
end
