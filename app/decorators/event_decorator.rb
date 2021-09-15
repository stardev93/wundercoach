class EventDecorator < ProductDecorator

  delegate_all

  require 'csv'

  def info_row
    start_date + ' ' + name + ' (' + h.t(:"#{type}") + ') ' + price
  end

  def name_with_date
    name + (start_date.present? ? " (#{start_date} - #{end_date})": '').to_s
  end

  def checkout_headline
    h.content_tag :h1 do
      h.content_tag(:span, h.t(:new_signup_headline)) +
        h.tag(:br) +
        h.content_tag(:span, %(#{object.eventtype} "#{object}"))
    end
  end

  def date_information
    unless object.start_date.blank?
      h.content_tag :p, class: "lead" do
        h.content_tag(:span, h.t(:event_date_information)) +
          h.tag(:br) +
          h.content_tag(:span, h.l(object.start_date, format: :default))
      end
    end
  end

  # the block methods are used for polymorphic product rendering
  def info_block
    # kill this. It is no good design and must not be used. Use
    # use = render "signup/products/info_row", :event => @product.decorate instead
    h.render "signup/products/info_block", event: self
  end

  def confirmation_block
    h.render "signup/events/confirm", event: self
  end

  # DATE FUNCTIONS
  # show date in signup views
  def date?
    true
  end

  # Start / End date
  def start_date
    if object.start_date
      l object.start_date.in_time_zone(object.account.get_time_zone), format: :short
    end
  end

  def start_time
    unless object.start_date.blank?
      object.start_date.in_time_zone(object.account.get_time_zone).strftime('%H:%M') + ' ' + I18n.t('oclock').html_safe
    end
  end

  def start_date_time
    if start_date && start_time
      start_date + ' ' + start_time
    end
  end

  def end_date
    if object.end_date
      l object.end_date.in_time_zone(object.account.get_time_zone), format: :short
    end
  end

  def end_time
    unless object.end_date.blank?
      object.end_date.in_time_zone(object.account.get_time_zone).strftime('%H:%M') + ' ' + I18n.t('oclock').html_safe
    end
  end

  def end_date_time
    if end_date && end_time
      end_date + ' ' + end_time
    end
  end

  # latest signup date
  def latest_signup_date_time
    if latest_signup_date && latest_signup_time
      latest_signup_date + ' ' + latest_signup_time
    end
  end

  def latest_signup_date
    if object.latest_signup_date
      l object.latest_signup_date.in_time_zone(object.account.get_time_zone), format: :short
    end
  end

  def latest_signup_time
    unless object.latest_signup_date.blank?
      object.latest_signup_date.in_time_zone(object.account.get_time_zone).strftime('%H:%M') + ' ' + I18n.t('oclock').html_safe
    end
  end


  # PRICING FUNCTIONS
  # the price at current time - can be full_price or early booking price
  def price
    if object.price.present?
      h.money_to_currency(object.price)
    end
  end

  # the price at current time - can be full_price or early booking price
  def full_price
    if object.full_price.present?
      h.money_to_currency(object.full_price)
    end
  end

  # the price when early booking applies
  def price_early_signup
    if object.price_early_signup.present?
      h.money_to_currency(object.price_early_signup)
    end
  end

  def early_signup_deadline
    if early_signup_deadline_date && early_signup_deadline_time
      early_signup_deadline_date + ' ' + early_signup_deadline_time
    end
  end

  def early_signup_deadline_date
    if object.early_signup_deadline
      l object.early_signup_deadline.in_time_zone(object.account.get_time_zone), format: :short
    end
  end

  def early_signup_deadline_time
    unless object.early_signup_deadline.blank?
      object.early_signup_deadline.in_time_zone(object.account.get_time_zone).strftime('%H:%M') + ' ' + I18n.t('oclock').html_safe
    end
  end

  def vat_rate
    if vat
      "#{h.number_to_percentage(object.vat_rate * 100, precision: 2, locale: I18n.locale)}"
    else
      nil
    end
  end

  def vat_sum
    h.money_to_currency(object.vat_sum)
  end

  def net_price
    if object.price.present?
      h.money_to_currency(object.net_price)
    end
  end

  def gross_price
    if object.price.present?
      h.money_to_currency(object.gross_price)
    end
  end

  def get_subevent_total
    h.money_to_currency(object.get_subevent_total)
  end

  # location methods: use associated product_location relation or event fields
  # depending on use_product_location

  def get_zip_and_city
    "#{object.get_zip}#{object.get_zip.blank? ? '' : ' '}#{object.get_city}"
  end

  # get country as translated full name
  def get_country_name
    unless self.new_record?
      if object.use_product_location
        country_obj = ISO3166::Country[product_location&.country]
      else
        country_obj = ISO3166::Country[country]
      end
      unless country_obj.nil?
        country_obj.translations[I18n.locale.to_s] || country_obj.name
      end
    end
  end

  def get_google_maps_link
    if use_product_location
      product_location&.decorate&.get_google_maps_link
    elsif object.full_street_address
      return h.link_to I18n.t(:open_in_google_maps), "https://www.google.com/maps/search/?api=1&query=#{object.eventorganizer},#{object.location},#{object.street} #{object.streetno},#{object.zip},#{object.city},#{object.country}", target: "_blank"
    else
      nil
    end
  end

  def summary
    return (object.scheduled? ? '' : '<strong>offline</strong><br>').to_s + '<strong>' + I18n.t(:start_date) + ' - ' + I18n.t(:end_date) + '</strong><br>' + start_date.to_s + ' - ' + end_date.to_s + '<br>' + '<strong>' + I18n.t(:start_time) + ' - ' + I18n.t(:end_time) + '</strong><br>' + start_time.to_s + ' - ' + end_time.to_s + '<br><br>' + shortdescription.to_s + '<br><br><strong>' + I18n.t(:location) + '</strong><br>' + location.to_s + '<br>' + eventorganizer.to_s + '<br>' + city.to_s
  end

  def info
    "#{object.name}" + "#{start_date ? ' ' + start_date : ''}" + "#{end_date ? ' - ' + end_date : ''}"
  end

  def webinar_additional_information
    if object.webinar_additional_information.present?
      object.webinar_additional_information.html_safe
    else
      I18n.t(:webinar_additional_information_hint_default)
    end
  end

  def get_event_contact
    object.get_event_contact.html_safe
  end
end
