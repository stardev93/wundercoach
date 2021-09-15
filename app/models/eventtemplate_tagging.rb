# adds tagging functionality to events and eventtemplates
class EventtemplateTagging < ActiveRecord::Base
  acts_as_tenant(:account)
  belongs_to :eventtemplate
  belongs_to :tag, class_name: "Product::Tag", foreign_key: "event_tag_id"

  def to_s
    tag.name
  end
end
