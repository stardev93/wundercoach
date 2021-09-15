class Planningstatus < ActiveRecord::Base
  has_many :accounts

  default_scope { order('position') }
  scope :planned, -> { where(key: 'planned') }
  translates :name, :description
  def to_s
    name
  end
end
