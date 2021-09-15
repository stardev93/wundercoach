## app/inputs/date_time_picker_input.rb
class DateTimePickerInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    template.content_tag(:div, class: 'input-group date form_datetime') do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat span_remove
    end
  end

  def input_html_options
    { class: 'form-control' }
  end

  def span_remove
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_remove
    end
  end

  def span_table
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_table
    end
  end

  def icon_remove
    "<i class='fa fa-calendar'></i>".html_safe
  end

  def icon_table
    "<i class='fa fa-remove'></i>".html_safe
  end
end
