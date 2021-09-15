module Product
  # adds tagging functionality to events and eventtemplates
  class Tagging < ActiveRecord::Base
    acts_as_tenant(:account)

    belongs_to :event, foreign_key: "event_id"
    belongs_to :eventtemplate, foreign_key: "event_id", class_name: "Event"
    belongs_to :tag, class_name: "Product::Tag", foreign_key: "event_tag_id"

    def to_s
      tag.name
    end
  end
end
