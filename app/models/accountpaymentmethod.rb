# Join model Account <-> Paymentmethod
class Accountpaymentmethod < ActiveRecord::Base
  acts_as_tenant(:account)
  belongs_to :paymentmethod

  validates :account_id, :paymentmethod_id, presence: true

  delegate :requires_configuration, to: :paymentmethod

  def to_s
    account.name
  end

  def activate
    self.is_active = true
  end

  # deactivate the accountpaymentmethod
  # remove from eventpaymentmethods
  def deactivate
    update!(is_active: false)
    Eventpaymentmethod.where("paymentmethod_id = ?", id).destroy_all
  end
end
