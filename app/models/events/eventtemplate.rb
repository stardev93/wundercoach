# Template of an event.
class Eventtemplate < Event
  # removed, as tenancy is already set up in superclass
  #acts_as_tenant(:account)

  extend FriendlyId
  friendly_id :name, use: :slugged

  monetize :full_price_cents, with_model_currency: :currency, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_early_signup_cents, with_model_currency: :currency, allow_nil: true

  before_save :initialize_seo_settings

  validates :maxparticipants, presence: true
  validates :maxparticipants, numericality: { greater_than_or_equal_to: 0 }

  has_many :events, class_name: "Event", foreign_key: "eventtemplate_id", dependent: :nullify

  # ToDo: refine this to allow non-free events with multiple participants
  # today additional_participants don't get billed
  validate :max_additional_participants_for_free_eventtemplates_only

  validates_with EventtemplateEarlyBookingValidator
  validates_with FriendlyUrlValidator
  # validates_format_of :slug, :with => /\A[a-z0-9\d-]+\z/i

  def early_booking_price_applies?
    early_signup_pricing
  end

  def max_additional_participants_for_free_eventtemplates_only
    if price_early_signup_cents.nil?
      price_early_signup_cents = 0
    end
    if additional_participants? && (!free? or price_early_signup_cents.positive?)
      errors.add(:max_additional_participants, I18n.t(:max_additional_participants_only_for_free_events))
    end
  end

  def additional_participants?
    max_additional_participants.present? && max_additional_participants.positive?
  end

  def free?
    price.blank? || price.zero?
  end

  # duplicate self and return copy
  def duplicate
    return EventDuplicate.new(self).perform
    # eventtemplate = deep_clone include: [:product_taggings]
    # eventtemplate.max_additional_participants = 0
    # # include: :paymentmethods
    # # eventtemplate.onlinestatus = Onlinestatus.find_by key: 'offline'
    # # eventtemplate.planningstatus = Planningstatus.find_by key: 'not_planned'
    # eventtemplate.save!
    #
    # eventtemplate
  end

  private

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [:name, %i(name city)]
  end

  def should_generate_new_friendly_id?
    new_record? || slug.nil? || slug.blank?
    # || name_changed?
  end

  def initialize_seo_settings
    self.meta_title = name if meta_title.blank?
    self.meta_description = shortdescription if meta_description.blank?
    self.use_tracking = true if new_record?
  end
end
