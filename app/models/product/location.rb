module Product
  class Location < ActiveRecord::Base
    # manages locations where events take place.
    # Relations: has_many events (ToDo)

    self.table_name = "product_locations"
    acts_as_tenant(:account)
    belongs_to :account
    has_many :events, dependent: :nullify, foreign_key: "product_location_id"

    monetize :cost_fixed_cents, :cost_variable_cents, with_model_currency: :currency, allow_nil: true
    PRICE_UNIT_HASH = { "h" => "per_hour", "d" => "per_day" }.freeze

    include HasCountry

    geocoded_by :full_street_address

    has_attached_file :icon, styles: { marker: "32x32>", thumb: "128x128>" }
    validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/

    has_attached_file :directionspdf
    validates_attachment :directionspdf, content_type: { content_type: 'application/pdf' }

    after_validation :geocode, unless: "full_street_address.nil?"
    after_validation :clear_coordinates, if: "geocoded? && full_street_address.nil?"

    scope :by_name, -> { order("location_name ASC") }

    validates_presence_of :location_name

    #validates_numericality_of :latitude, allow_nil: true
    #validates_numericality_of :longitude, allow_nil: true

    def to_s
      location_name
    end

    # used for geocoding
    def full_street_address
      [street, zip, city, state, country].compact.join(', ')
    end

  end
end
