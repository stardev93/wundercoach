class PaymentAdapter < ActiveRecord::Base
  acts_as_tenant(:account)

  # prevent multiple adapters of the same kind, e.g. multiple credit cards
  validates_uniqueness_to_tenant :type

  def to_s
    I18n.t("activerecord.models.#{self.class.name}")
  end

end
