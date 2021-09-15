# displays a percentage addon next to the input
class PercentageInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options)
    template.content_tag(:div, class: 'input-group') do
      input_html_options[:step] = 0.01
      super(wrapper_options) + template.content_tag(:div, '%', class: 'input-group-addon')
    end
  end
end
