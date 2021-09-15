class Appversion < ActiveRecord::Base
  has_many :features
  has_many :paymentplans

  scope :current, -> { where(version_number: Appversion.maximum(:version_number)) }

  def to_s
    name
  end
end
