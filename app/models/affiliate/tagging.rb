class Affiliate < ActiveRecord::Base
  # adds tagging functionality to events and eventtemplates
  class Tagging < ActiveRecord::Base
    belongs_to :affiliate
    belongs_to :event
    belongs_to :tag, class_name: 'Affiliate::Tag', foreign_key: 'affiliate_tag_id'

    def to_s
      name
    end
  end
end
