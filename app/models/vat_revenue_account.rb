class VatRevenueAccount < ActiveRecord::Base
  acts_as_tenant(:account)

  belongs_to :account
  belongs_to :vat

  validates_uniqueness_to_tenant :vat_id
  validates :revenue_account, presence: true

  def to_s
    revenue_account
  end
end
