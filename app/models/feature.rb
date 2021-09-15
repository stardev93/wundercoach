class Feature < ActiveRecord::Base
  translates :name, :description
  validates :appversion, :name, :key, :fieldtype, presence: true
  acts_as_list scope: :appversion

  belongs_to :appversion
  has_many :paymentplans, through: :paymentplanfeatures

  has_many :paymentplanfeatures, dependent: :destroy

  scope :default_order, -> { joins(:appversion).order("features.position, appversions.version_number DESC") }

  default_scope -> { default_order }

  def to_s
    name
  end
end
