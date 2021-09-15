# a StandardEvent occurs at a specific time and costs money
# it can be booked online and has multiple attendants from multiple clients
class StandardEvent < Event
  validates :maxparticipants, :full_price, presence: true
  validates :full_price, numericality: { greater_than_or_equal_to: 0 }
  validates :maxparticipants, numericality: { greater_than_or_equal_to: 0 }
  validates :price_early_signup, presence: true, if: 'early_signup_pricing'
  validates :early_signup_deadline, presence: true, if: 'early_signup_pricing', on: :update
  validates_presence_of :paymentmethods
  validate :gocardless_compatible_currency, if: 'paymentmethods.pluck(:key).include? "direct_debit"'
  validate :sofort_compatible_currency, if: 'paymentmethods.pluck(:key).include? "sofort"'
  # TODO: improve money_transfer_and_spot_cash validation, so we can include it again
  # auto-generated events usually fail this validation
  # validate :money_transfer_and_spot_cash_exclude_each_other
  belongs_to :eventtemplate, class_name: "Eventtemplate", foreign_key: "eventtemplate_id", required: false

  # required by url_helpers
  def self.model_name
    Event.model_name
  end

  private

  def gocardless_compatible_currency
    unless currency.in? %w(EUR)
      errors.add(:paymentmethods, :only_eur_supported)
    end
  end

  def sofort_compatible_currency
    unless currency.in? %w(EUR)
      errors.add(:paymentmethods, :only_eur_supported)
    end
  end

  def money_transfer_and_spot_cash_exclude_each_other
    if paymentmethods.where(key: %w(banktransfer vorkasse)).count >= 2
      errors.add(:paymentmethods,
                 'Überweisung und Vorkasse schließen einander aus.')
    end
  end
end
