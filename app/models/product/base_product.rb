module Product
  class BaseProduct < ActiveRecord::Base
    acts_as_tenant(:account)

    include HasCountry
    include Filterable
    include ActsAsProduct

    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged

    monetize :price_cents, with_model_currency: :currency, allow_nil: true

    # Validations
    validates :name, presence: true
    validates_length_of :name, :slug, maximum: 255
    validates :slug, uniqueness: true

    def to_s
      name
    end

  end
end
