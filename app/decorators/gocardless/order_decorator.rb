# Used in Signup Controller for Gocardless Payment
# Not to be used for account payment (see PaymentAdapters for that)
class Gocardless::OrderDecorator < Draper::Decorator
  delegate_all

  def amount
    object.price.cents
  end

  def mandate
    object.gocardless_mandate_id
  end

  def session_token
    h.session.id
  end

  def description
    object.product.name
  end

  def success_redirect_url
    h.signup_gocardless_success_url(object)
  end

  def access_token
    object.account.gocardless_access_token
  end

  def redirect_flow_id
    object.gocardless_redirect_flow_id
  end
end
