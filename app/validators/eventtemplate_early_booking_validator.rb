class EventtemplateEarlyBookingValidator < ActiveModel::Validator
  def validate(record)
    if record.early_signup_pricing && record.price_early_signup_cents.nil?
      record.errors[:price_early_signup] << I18n.t(:eventtemplate_early_booking_needs_price)
    end
  end
end
