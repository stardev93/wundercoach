# utility view helpers for accounts
class CoachDecorator < Draper::Decorator
  delegate_all

  def to_s
    (gender.blank? || gender == 'noinfo' ? '' : gender_indirect.to_s + ' ') + (title ? title.to_s + ' ' : '') + (firstname ? firstname.to_s + ' ' : '') + (lastname ? lastname.to_s : '')
  end

  def name
    to_s
  end

  def name
    to_s
  end

  def reverse_name
    (lastname ? lastname.to_s + ', ' : '') + (firstname.blank? ? '' : firstname.to_s) + (title ? title.to_s + ' ' : '')
  end

  def price_unit
    if object.price_unit == 'h'
      I18n.t(:per_hour)
    else
      I18n.t(:per_day)
    end
  end

  def price
    h.number_to_currency(object.price)
  end

  def price_w_unit
    h.number_to_currency(object.price).to_s + ' ' + price_unit.to_s
  end

  def gender
    I18n.t(:"#{object.gender}") unless object.gender.blank?
  end

  def gender_indirect
    I18n.t(:"#{object.gender}_indirect") unless object.gender.blank?
  end
end
