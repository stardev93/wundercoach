class Eventpaymentmethod < ActiveRecord::Base
  acts_as_tenant(:account)
  belongs_to :event
  belongs_to :paymentmethod
end
