class Product::PricingoptionDecorator < Draper::Decorator
  delegate_all

  def full_price_deduct
    if object.full_price_deduct.present?
      h.money_to_currency(object.full_price_deduct || 0)
    end
  end

  def price_early_signup_deduct
    if object.price_early_signup_deduct.present?
      h.money_to_currency(object.price_early_signup_deduct || 0)
    end
  end

  def full_price_deduct_perc
    if object.full_price_deduct_perc.present?
      h.number_to_percentage(object.full_price_deduct_perc || 0)
    end
  end

  def price_early_signup_deduct_perc
    if object.price_early_signup_deduct_perc.present?
      h.number_to_percentage(object.price_early_signup_deduct_perc || 0)
    end
  end

  # returns event.full_price_cents after deduction of absolute or percentage value
  def full_price(event)
    h.money_to_currency(object.full_price(event) || 0)
  end

  # returns event.price_early_signup_cents after deduction of absolute or percentage value
  def price_early_signup(event)
    h.money_to_currency(object.price_early_signup(event) || 0)
  end

  def price(event)
    h.money_to_currency(object.price(event) || 0)
  end

  # get the deduction for this option,
  # i.e. with or without early booking discount
  # and as percentage or absolute
  def deduction(event)
    # does early booking apply?
    if is_absolute?
      h.money_to_currency(object.deduction(event) || 0)
    else
      h.number_to_percentage(object.deduction(event) || 0)
    end
  end

  def net_price(event)
    h.money_to_currency(object.net_price(event) || 0)
  end

  def gross_price(event)
    h.money_to_currency(object.gross_price(event) || 0)
  end

  def vat_sum(event)
    h.money_to_currency(object.vat_sum(event) || 0)
  end

  def vat_rate(event)
    h.number_to_percentage(object.vat_rate(event) * 100 || 0)
  end
end
