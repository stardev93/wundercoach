# PayPal SANDBOX API CREDENTIALS
# office-facilitator@wundercoach.net
# Client ID: AeoS9vV2zl6C6RnVP-pjZKZpbWyAnP2D-U32ZUh9F1Ep1UNGlrAVjvpHO4XhhTwZSIpaqfEIHdaZDnQg
# Secret: EHGQBtCohpksKlyvTrR5GW0-AoQgZWenjBHVVcZb9W4_jp4xx5s3U1ZSBQ5zkP27KcuZt7DUx3lMOb_N
# Live Information goto: https://developer.paypal.com/developer/applications/edit/

class Paymentmethod < ActiveRecord::Base
  has_many :invoices
  has_many :eventpaymentmethods, dependent: :destroy
  has_many :accountpaymentmethods, dependent: :destroy

  has_many :paymentterms

  scope :allowed, -> { joins(:accountpaymentmethods).where(accountpaymentmethods: { is_active: true }) }
  scope :non_free, -> { where.not(key: 'free') }

  translates :name, :comment, :thankyou_text

  def to_s
    name
  end

  # return the first element of the has_many association to paymentterm
  def paymentterm
    paymentterms.first
  end

  def online_payment?
    %w(sofort cc direct_debit paypal).include? key
  end

  def requires_configuration?
    %w(sofort paypal).include? key
  end

  def requires_integration?
    %w(sofort cc direct_debit).include? key
  end
end
