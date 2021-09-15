json.array!(@eventsessions) do |eventsession|
  json.extract! eventsession, :id, :name
  json.allDay false
  json.startEditable true
  json.durationEditable true
  json.title eventsession.name
  json.description eventsession.comments
  json.start eventsession.start
  json.end eventsession.end
  json.url eventsession_url(eventsession, format: :html)
end
