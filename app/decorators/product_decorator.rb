class ProductDecorator < Draper::Decorator
  delegate_all

  def formatted_price
    if object.free?
      h.t(:free_of_charge)
    else
      h.money_to_currency(object.price)
    end
  end

  def date_information
    "".html_safe
  end
end
