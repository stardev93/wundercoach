class Coach < ActiveRecord::Base
  acts_as_tenant(:account)

  has_attached_file :image,
    styles: {medium: '300x600^', thumb: '100x200>'},
    :url  => "/system/coaches/:id/:style/:basename.:extension",
    #:coach => "/assets/coaches/:id/:style/:basename.:extension",
    default_url: 'coach/:style/coach-default.png'

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  has_and_belongs_to_many :events

  monetize :price_cents, with_model_currency: :currency, allow_nil: true

  # Scopes
  scope :by_name, -> { order('lastname, firstname') }
  scope :active, -> { where(active: true) }
  scope :unassigned, ->(event) { where.not(id: event.coaches.pluck(:id)) }

  PRICE_UNIT_HASH = { "h" => "per_hour", "d" => "per_day" }.freeze

  def to_s
    "#{lastname}, #{firstname}"
  end

  def coachurl
    return "<a href='#{}'>#{firstname} #{lastname}</a>"
  end
end
