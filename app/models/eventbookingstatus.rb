class Eventbookingstatus < ActiveRecord::Base
  scope :except_new, -> { where.not(key: 'new') }
  default_scope -> { order('position') }
  has_many :eventbookings

  translates :name, :description
  include Filterable
  def to_s
    name
  end
end
