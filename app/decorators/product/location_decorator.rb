class Product::LocationDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def to_s_with_city
    "#{location_name}/#{zip} #{city}"
  end

  def country_name
    retval = ISO3166::Country[country]
    retval.translations[I18n.locale.to_s] || retval.name if retval
  end

  # computed address used by google
  # location.rb: full_street_address using street, zip, city, state, country
  def google_location
    "#{(street.blank? ? '' : street + '<br>')}
    #{(street_no.blank? ? '' : street_no + '<br>')}
    #{(zip.blank? ? '' : zip + '&nbsp;')}#{(city.blank? ? '' : city + '<br>')}
    #{(state.blank? ? '' : state + '<br>')}
    #{(country_name.blank? ? '' : country_name)}".html_safe
  end

  def displayed_address
    # display object.displayed_address as textfield or combine address fields
    if object.displayed_address.blank?
      "#{(eventorganizer_name.blank? ? '' : eventorganizer_name + '<br>')}
      #{(street.blank? ? '' : street)}#{(street_no.blank? ? '' : ' ' + street_no + '<br>')}
      #{(zip.blank? ? '' : zip + '&nbsp;')}#{(city.blank? ? '' : city + '<br>')}
      #{(state.blank? ? '' : state + '<br>')}
      #{(country_name.blank? ? '' : country_name)}".html_safe
    else
      object.displayed_address.html_safe
    end
  end

  def get_google_maps_link
    #return h.link_to I18n.t(:open_in_google_maps), "https://www.google.com/maps/search/?api=1&query=#{object.latitude},#{object.longitude}", target: "_blank"
    return h.link_to I18n.t(:open_in_google_maps), "https://www.google.com/maps/search/?api=1&query=#{object.eventorganizer_name},#{object.location_name},#{object.street} #{object.street_no},#{object.zip},#{object.city},#{object.country}", target: "_blank"
  end

  def cost_variable_unit
    if object.cost_variable_unit == 'h'
      I18n.t(:per_hour)
    else
      I18n.t(:per_day)
    end
  end

  def cost_variable_w_unit
    h.number_to_currency(object.cost_variable).to_s + ' ' + price_unit.to_s
  end

  def location_info
    "#{location_name}, #{zip} #{(city.nil? ? '' : ' ' + city.to_s)}#{(street.nil? ? '' : ', ' + street.to_s)}#{(street_no.nil? ? '' : ' ' + street_no.to_s)}#{(state.nil? ? '' : ', ' + state.to_s)}#{(country_name.nil? ? '' : ', ' + country_name.to_s)}"
  end
end
