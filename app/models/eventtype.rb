class Eventtype < ActiveRecord::Base
  acts_as_tenant(:account)

  validates_uniqueness_to_tenant :key
  validates_uniqueness_to_tenant :name

  validates :key, presence: true
  validates :name, presence: true

  translates :name, :description

  has_many :events, dependent: :nullify

  def to_s
    name
  end
end
