# Models return their country's name instead of it's ISO3166-country-code
# https://github.com/stefanpenner/country_select
module HasCountry
  extend ActiveSupport::Concern
  included do
    # This will attempt to translate the country name and use the default
    # (usually English) name if no translation is available
    def country_name
      return '' if read_attribute(:country).blank?
      country = ISO3166::Country[read_attribute(:country)]
      country.translations[I18n.locale.to_s] || country.name
    end
  end
end
