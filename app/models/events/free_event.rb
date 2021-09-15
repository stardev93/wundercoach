# FreeEvents are not charged
# they have paymentmethod 'free' and produce no invoices
# their price is 0
# signup process skips payment step
class FreeEvent < Event
  before_validation(on: :create) { paymentmethods << Paymentmethod.find_by(key: 'free') }

  validates :maxparticipants, presence: true, numericality: { greater_than_or_equal_to: 0 }
  belongs_to :eventtemplate, class_name: "Eventtemplate", foreign_key: "eventtemplate_id"

  # required by url_helpers
  def self.model_name
    Event.model_name
  end

  # never generate invoices for free events
  # overrides the value stored in the database
  def generate_invoice
    false
  end

  # don't add paymentmethods, since Paymentmethod 'free' is assinged on create
  # and no other paymentmethods are required
  def add_paymentmethods; end
end
