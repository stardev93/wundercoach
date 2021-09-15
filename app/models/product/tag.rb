module Product
  # adds tagging functionality to events and eventtemplates
  class Tag < ActiveRecord::Base
    acts_as_tenant(:account)

    scope :by_name, -> { order("name") }

    has_many :product_taggings, class_name: "Product::Tagging", foreign_key: "event_tag_id", dependent: :destroy

    has_many :events, -> { no_eventtemplates }, through: :product_taggings
    has_many :eventtemplates, -> { eventtemplates }, through: :product_taggings


    validates_uniqueness_to_tenant :name
    validates :name, presence: true

    def to_s
      name
    end
  end
end
