class ProductPricingsetValidator < ActiveModel::Validator

  def validate(record)

    if record.name.nil? || record.name == ''
      record.errors[:name] << I18n.t("errors.messages.empty")
    end

    if record.hint_text.nil? || record.hint_text == ''
      record.errors[:hint_text] << I18n.t("errors.messages.empty")
    end

    if record.active && record.pricingoptions.with_preset.count == 0
      record.errors[:base]  << I18n.t(:pricingoption_preset_missing)
    end
  end

end
