class BundleDecorator < ProductDecorator
  def checkout_headline
    h.content_tag :h1 do
      h.content_tag(:span, h.t(:booking)) +
        h.tag(:br) +
        h.content_tag(:span, %("#{bundle}"))
    end
  end

  def info_block
    # kill this. It is no good design and must not be used. Use
    # use = render "signup/products/info_row", :event => @product.decorate instead
    h.render "signup/bundles/info_block", bundle: self
  end

  def confirmation_block
    h.render "signup/bundles/confirm", bundle: self
  end

  # don't show date block in signup views
  def date?
    false
  end

  # don't show location block in signup views
  def location?
    false
  end

  def start_date
    if object.start_date
      l object.start_date, format: :short
    end
  end

  def start_time
    unless object.start_date.blank?
      object.start_date.strftime('%H:%M') + ' ' + I18n.t('oclock').html_safe
    end
  end

  def end_date
    if object.end_date
      l object.end_date, format: :short
    end
  end

  def end_time
    unless object.end_date.blank?
      object.end_date.strftime('%H:%M') + ' ' + I18n.t('oclock').html_safe
    end
  end

  def price
    if object.price.present?
      h.money_to_currency(object.price)
    end
  end

  def vat_rate
    if vat
      "#{h.number_to_percentage(object.vat_rate * 100, precision: 2, locale: I18n.locale)}"
    else
      nil
    end
  end

  def vat_sum
    h.money_to_currency(object.vat_sum)
  end

  def net_price
    if object.price.present?
      h.money_to_currency(object.net_price)
    end
  end

  def gross_price
    if object.price.present?
      h.money_to_currency(object.gross_price)
    end
  end

end
