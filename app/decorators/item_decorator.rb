class ItemDecorator < Draper::Decorator
  delegate_all

  def price
    if object.price.present?
      h.money_to_currency(object.price)
    end
  end
end
