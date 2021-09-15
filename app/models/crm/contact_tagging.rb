class Crm::ContactTagging < ActiveRecord::Base
  acts_as_tenant(:account)
  self.table_name = "contact_taggings"

  belongs_to :account
  belongs_to :contact
  belongs_to :contact_tag

  def to_s
    contact_tag.name
  end
end
