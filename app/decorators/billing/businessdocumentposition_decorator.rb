class Billing::BusinessdocumentpositionDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def unit_price
    h.money_to_currency(object.unit_price)
  end

  def price_cents
    h.money_to_currency(object.price)
  end

  def total_price
    h.money_to_currency(object.total_price)
  end

  def total_vat_amount
    h.money_to_currency(object.total_vat_amount)
  end

  def amount
    if h.numeric?(object.amount)
      h.number_with_precision(object.amount, precision: 2, locale: I18n.locale)
    else
      0
    end
  end

  def vat_rate
    if h.numeric?(object.vat_rate)
      h.number_to_percentage(object.vat_rate * 100, precision: 2, locale: I18n.locale)
    else
      0
    end
  end

  def description
    return h.sanitize object.description.html_safe unless object.description.blank?
  end

  def businessdocument
    return object.businessdocument.decorate
  end
end
