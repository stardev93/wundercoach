json.array!(@eventsessionbookings) do |eventsessionbooking|
  json.extract! eventsessionbooking, :id, :event_id, :eventsession_id, :user_id, :eventsessionbookingstatus
  json.url eventsessionbooking_url(eventsessionbooking, format: :json)
end
