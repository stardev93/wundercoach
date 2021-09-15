class Product::Pricingset < ActiveRecord::Base
  acts_as_tenant(:account)
  belongs_to :account

  validates_with ProductPricingsetValidator

  has_many :pricingoptions, dependent: :destroy
  has_many :events, dependent: :nullify, foreign_key: "product_pricingset_id"

  #accepts_nested_attributes_for :pricingoptions

  scope :active, -> { where(active: true) }
  scope :with_options, -> { includes(:pricingoptions) }

  def to_s
    if active
      name
    else
      "#{name} (#{I18n.t(:inactive)})"
    end
  end

  # return the first pricingoption with preset = true, i.e. default
  # the first record if preset is false on all pricingoptions
  def get_preset
    pricingoptions.find_by(:preset => true) || pricingoptions.first
  end
end
