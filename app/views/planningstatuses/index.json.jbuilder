json.array!(@planningstatuses) do |planningstatus|
  json.extract! planningstatus, :id, :key, :name, :description, :position
  json.url planningstatus_url(planningstatus, format: :json)
end
