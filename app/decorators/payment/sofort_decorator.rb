# TODO: Rename into Sofort::OrderDecorator
# Wrap your orders, so they can provide all data necessary for sofort.com
class Payment::SofortDecorator < Draper::Decorator
  delegate_all

  def success_url
    h.signup_sofort_success_url(object, '-TRANSACTION-')
  end

  def abort_url
    h.payment_signup_order_url(object)
  end

  def api_key
    account.sofort_api_key
  end

  def project_id
    account.sofort_project_id
  end

  def user_id
    account.sofort_user_id
  end

  def amount
    h.number_with_precision(object.price, precision: 2, locale: :en)
  end

  def holder
    address.fullname
  end

  def country_code
    address.country
  end

  # truncates product name after 27 chars
  def reason_for_payment
    object.product[0..26]
  end

  # truncates account name after 27 chars
  def creditor
    object.account.name[0..26]
  end

  def ready_for_transaction?
    [amount, success_url, abort_url].all?(&:present?)
  end

  private

  def address
    object.invoice_address
  end

  def account
    @account ||= object.account
  end
end
