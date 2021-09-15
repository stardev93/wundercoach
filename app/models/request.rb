# If you want to book an IndividualEvent, you first send a request
# that includes your contact-info (like mail or telephone) and a message.
# Requests can reference an IndividualEvent, so you can create an
# eventbooking from it automatically
class Request < ActiveRecord::Base
  acts_as_tenant(:account)

  belongs_to :event
  belongs_to :generated_event, class_name: "Event"

  validates :firstname, :lastname, presence: true
  validates_presence_of :email
  validates :email, email: true

  scope :without_appointment, -> { where(generated_event: nil) }

  def full_name
    "#{firstname} #{lastname}"
  end

  def to_s
    I18n.t :request_from, name: full_name, date: I18n.l(created_at.to_date), event: event
  end

  def to_substitution_hash
    { "request" => self, "event" => event }
  end
end
