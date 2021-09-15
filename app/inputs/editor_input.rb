class EditorInput < SimpleForm::Inputs::TextInput
  def input(_wrapper_options)
    locales = { 'de' => 'de-DE', 'en' => 'en-US' }

    super(data: { locale: locales[I18n.locale.to_s] }, class: 'form-control')
  end
end
