class Affiliate < ActiveRecord::Base
  # adds tagging functionality to events and eventtemplates
  class Tag < ActiveRecord::Base
    belongs_to :affiliate
    has_many :taggings, class_name: 'Affiliate::Tagging', foreign_key: 'affiliate_tag_id'
    has_many :events, through: :taggings

    validates :name, uniqueness: { scope: :affiliate }
    validates :name, presence: true

    def to_s
      name
    end
  end
end
