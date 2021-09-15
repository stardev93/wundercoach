# Shared Behavior for products (e.g. Event, Bundle, ...)
module ActsAsProduct
  extend ActiveSupport::Concern

  # send notification on successful order?
  def notify?
    account.notification_url.present? && digimember_id.present?
  end

  # from the given currency-ISO-code, get the currency's Unit
  def currency_unit
    currencies[currency]
  end

  # tells if a product can and is crm-enabled (like events)
  def crm_enabled?
    respond_to?(:enable_crm) && enable_crm
  end
end
