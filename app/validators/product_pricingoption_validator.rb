class ProductPricingoptionValidator < ActiveModel::Validator

  def validate(record)

    if record.name.nil? || record.name == ''
      record.errors[:name] << I18n.t("errors.messages.empty")
    end

    if record.hint_text.nil? || record.hint_text == ''
      record.errors[:hint_text] << I18n.t("errors.messages.empty")
    end

    if record.full_price_deduct_cents.nil? && record.full_price_deduct_perc.nil?
      record.errors[:full_price_deduct_cents] << I18n.t(:pricingoption_needs_absolute_or_percentage_values)
      record.errors[:full_price_deduct_perc] << I18n.t(:pricingoption_needs_absolute_or_percentage_values)
    end

    if record.price_early_signup_deduct_cents.nil? && record.price_early_signup_deduct_perc.nil?
      record.errors[:price_early_signup_deduct_cents] << I18n.t(:pricingoption_needs_absolute_or_percentage_values)
      record.errors[:price_early_signup_deduct_perc] << I18n.t(:pricingoption_needs_absolute_or_percentage_values)
    end

  end

end
