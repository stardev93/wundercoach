class Affiliate < ActiveRecord::Base
  # groups events by tags, cross-account
  class EventList < ActiveRecord::Base
    belongs_to :affiliate
    has_and_belongs_to_many :tags, foreign_key: :affiliate_event_list_id, association_foreign_key: :affiliate_tag_id
    has_many :events, -> { distinct }, through: :tags

    def to_s
      name
    end
  end
end
