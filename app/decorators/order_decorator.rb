class OrderDecorator < Draper::Decorator
  delegate_all

  def fullname
    object.address.fullname
  end

  def fullname_backwards
    "#{object.address.lastname}, #{object.address.firstname}"
  end

  def product_name
    if object.product
      "#{object.product.model_name.human} #{object.product}"
    else
      "unbekannt"
    end
  end

  # which class to use in breadcrumb navi
  def checkout_class
    "step-#{checkout_step}"
  end

  # based on the order's status, which checkout is the current one?
  def checkout_step
    case object.status
    when "just_started"
      1
    when "data_completed"
      2
    when "payment_chosen"
      3
    when %w(confirmed waiting_for_payment paid)
      4
    end
  end

  def price
    if object.price.present?
      h.money_to_currency(object.price)
    end
  end

  def net_price
    h.money_to_currency(object.net_price || 0)
  end

  def gross_price
    h.money_to_currency(object.gross_price || 0)
  end

  def vat_sum
    h.money_to_currency(object.vat_sum || 0)
  end

  def vat_rate
    h.number_to_percentage(object.vat_rate * 100 || 0)
  end

  def order_date
    if object.order_date
      l object.order_date.in_time_zone(object.account.get_time_zone), format: :short
    end
  end

  def order_time
    unless object.order_date.blank?
      object.order_date.in_time_zone(object.account.get_time_zone).strftime('%H:%M') + ' ' + I18n.t('oclock').html_safe
    end
  end
end
