class Crm::ContactTag < ActiveRecord::Base
  acts_as_tenant(:account)
  self.table_name = "contact_tags"

  belongs_to :account

  has_many :contact_taggings, class_name: "Crm::ContactTagging", foreign_key: "contact_tag_id", dependent: :destroy

  has_many :contacts, through: :contact_taggings

  validates_uniqueness_to_tenant :name
  validates :name, presence: true

  def to_s
    name
  end
end
