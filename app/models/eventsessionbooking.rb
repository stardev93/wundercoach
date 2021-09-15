class Eventsessionbooking < ActiveRecord::Base
  belongs_to :event
  belongs_to :eventsession
  belongs_to :user

  scope :upcoming, -> {joins(:eventsession).where("eventsessions.status = 'planned'").order("start_date ASC")}
  scope :passed, -> {joins(:eventsession).where("eventsessions.status = 'finished'").order("start_date ASC")}
end
