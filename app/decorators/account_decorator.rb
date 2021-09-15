# utility view helpers for accounts
class AccountDecorator < Draper::Decorator
  delegate_all

  def commission_relative
    h.number_to_percentage(object.affiliate_commission_relative || 0)
  end

  def commission_absolute
    h.number_to_currency(object.affiliate_commission_absolute || 0)
  end
end
