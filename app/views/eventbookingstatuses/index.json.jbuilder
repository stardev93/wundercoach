json.array!(@eventbookingstatuses) do |eventbookingstatus|
  json.extract! eventbookingstatus, :id, :key, :name, :description
  json.url eventbookingstatus_url(eventbookingstatus, format: :json)
end
