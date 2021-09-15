class TimePickerInput < DatePickerInput
  private

  def input
    template.content_tag(:div, class: 'select form-control input-group date form_datetime') do
      # template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat @builder.select(attribute_name, 0..23, input_html_options)
      template.concat ':'
      template.concat @builder.select(attribute_name, 0..60, input_html_options)
    end
  end

  def display_pattern
    I18n.t('timepicker.dformat', default: '%R')
  end

  def picker_pattern
    I18n.t('timepicker.pformat', default: 'HH:mm')
  end

  def date_options
    date_options_base
  end
end
