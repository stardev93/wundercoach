# defines target groups for marketing campaigns
class Filter < ActiveRecord::Base
  acts_as_tenant(:account)
  has_and_belongs_to_many :target_groups, autosave: true

  default_scope { order(name: 'ASC') }

  validates :name, presence: true

  def to_s
    name
  end
end
