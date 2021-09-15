class Billing::BusinessdocumentDecorator < Draper::Decorator
  delegate_all

  def type
    h.t(:"#{object.type}")
  end

  def net_sum
    h.money_to_currency(object.net_sum)
  end

  def vat_sum
    h.money_to_currency(object.vat_sum)
  end

  def gross_sum
    h.money_to_currency(object.gross_sum)
  end

  def recipient_address
    if object.order
      order.invoice_address
    else
      object.recipient_name1
    end
  end

  def invoice_date
    if object.invoice_date
      l object.invoice_date.in_time_zone(object.account.get_time_zone), format: :short
    end
  end

  def info
    "#{to_s} #{invoice_date} #{gross_sum}"
  end

end
