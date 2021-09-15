json.array!(@eventsessions.planned) do |eventsession|
  json.extract! eventsession, :id, :name
  json.title eventsession.name
  json.description eventsession.comments
  json.allDay false
  json.startEditable true
  json.durationEditable false
  json.title eventsession.name
  json.start eventsession.start
  json.end eventsession.end
  json.url eventsession_url(eventsession, format: :html)
end
