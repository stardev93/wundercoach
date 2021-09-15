# lists all available currencies, ordered by priotiry, searchable
class CurrencyPickerInput < SimpleForm::Inputs::CollectionSelectInput
  def input(*)
    collection = AVAILABLE_CURRENCIES_SELECT

    label_method = :first
    value_method = :second

    @builder.collection_select(
      attribute_name, collection, value_method, label_method,
      input_options, input_html_options
    )
  end

  def input_html_classes
    super.push('chosen-select')
  end

  def input_options
    { include_blank: false }
  end
end
