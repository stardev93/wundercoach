json.array! @events do |event|
  json.id event.id
  json.title "#{event.name.to_s}" + " (#{event&.eventtype&.to_s})"
  json.start event.start_date
  json.end event.end_date
  json.url url_for event
  json.backgroundColor (event.scheduled? == true ? event&.eventtype&.decorate.colorcode : '')
  json.borderColor (event.scheduled? == true ? event&.eventtype&.decorate.colorcode : '')
  json.className (event.scheduled? != true ? 'fc-event-offline' : '')
  # json.coaches event.coaches do |coach|
  #   json.(coach, :id, :lastname, :firstname)
  # end
  json.description event.decorate.summary
end
