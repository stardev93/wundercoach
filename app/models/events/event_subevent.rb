class EventSubevent < ActiveRecord::Base

  acts_as_tenant(:account)
  self.table_name = "event_subevents"

  after_commit :update_parent_event

  belongs_to :event, class_name: "Event", foreign_key: "event_id"
  belongs_to :subevent, class_name: "Event", foreign_key: "subevent_id"

  scope :by_date, -> { joins(:subevent).order("events.start_date ASC") }
  scope :by_latest_signup_date, -> { joins(:subevent).order("events.latest_signup_date ASC") }
  scope :by_date_desc, -> { joins(:subevent).order("events.start_date DESC") }
  scope :by_maxparticipants, -> { joins(:subevent).order("events.maxparticipants ASC") }

  has_many :eventbookings, through: :event

  def to_s
    subevent.name.to_s
  end

  def seats_free
    #delegate seats_free to subevent
    subevent.seats_free
  end

  private

  # update BundleEvent attributes when changing subevents assignment
  def update_parent_event

    @bundle_event = BundleEventUpdateFromSubevent.new(event, subevent).perform

  end

end
