class Paymentterm < ActiveRecord::Base
  acts_as_tenant(:account)

  translates :name, :description
  validates_uniqueness_to_tenant :paymentmethod_id

  belongs_to :account
  belongs_to :paymentmethod

  CONTEXTS = ["checkout", 'invoice', "cancellation"]
  
  def to_s
    name
  end
end
