module Embedded
  # provides context for a widget based on an event
  # make the replacings for javascript event lists
  class EventDecorator < Draper::Decorator
    delegate_all
    attr_accessor :adpartner_id

    def context
      {
        'id' => object.id,
        'locale' => I18n.locale.to_s,
        'slug' => object.slug,
        'bottom_text' => object.bottom_text,
        'longdescription' => object.longdescription,
        'maxparticipants' => object.maxparticipants,
        'name' => object.name,
        'price' => price,
        'full_price' => full_price,
        'shortdescription' => object.shortdescription,
        'start_date' => start_date,
        'start_time' => object.start_time,
        'end_date' => end_date,
        'end_time' => object.end_time,
        'use_product_location' => object.use_product_location,
        'get_location' => object.get_location,
        'get_eventorganizer' => object.get_eventorganizer,
        'get_street' => object.get_street,
        'get_streetno' => object.get_streetno,
        'get_city' => object.get_city,
        'get_zip' => object.get_zip,
        'get_state' => object.get_state,
        'get_country' => object.get_country,
        'product_location' => object.product_location_id,
        'eventorganizer_name' => object&.product_location&.eventorganizer_name,
        'location_name' => object&.product_location&.location_name,
        'street_name' => object&.product_location&.street,
        'zip_name' => object&.product_location&.zip,
        'city_name' => object&.product_location&.city,
        'googlemapslocation' => get_google_maps_link,
        'location' => object.location,
        'city' => object.city,
        'state' => object.state,
        'country' => object.country,
        'eventorganizer' => object.eventorganizer,
        'street' => "#{object.street} #{object.streetno}",
        'zip' => object.zip,
        'coaches' => object.coaches.join('<br>'),
        'coach_list' => object.coaches.pluck(:lastname, :firstname, :homepage_url).join(','),
        'tags' => object.product_tags.pluck(:name).join(','),
        'show_link' => show_link,
        'details_link' => details_link,
        'signup_link' => signup_link,
        'button_fully_booked' => button_fully_booked,
        'paymentmethods' => paymentmethods,
        'remaining_seats' => object.seats_free,
        'account' => object.account.name,
        'early_signup_pricing' => early_signup_pricing,
        'early_signup_deadline' => early_signup_deadline,
        'early_signup_deadline_date' => early_signup_deadline_date,
        'early_signup_deadline_time' => early_signup_deadline_time,
        'type' => object.type,
        'eventtemplate_id' => object.eventtemplate_id,
        'early_booking_price_applies?' => object.early_booking_price_applies?,
        'eventtype' => object.eventtype.to_s,
        'subevents_assigned' => (object.subevents.map {|subevent| EventSubeventDecorator.new(subevent).context } if object.type == "BundleEvent"),
        'coaches_assigned' => (object.coaches.map {|coach| CoachDecorator.new(coach).context })
      }
    end

    def subdomain
      object.account.subdomain
    end

    def get_google_maps_link
      return h.link_to I18n.t(:open_in_google_maps), "https://www.google.com/maps/search/?api=1&query=#{object.product_location&.eventorganizer_name},#{object.product_location&.location_name},#{object.product_location&.street},#{object.product_location&.zip},#{object.product_location&.city},#{object.product_location&.country}", target: "_blank"
    end

    private

    def start_date
      (h.l(object.start_date.to_date) + "," +
        h.tag("br") +
        h.l(object.start_date.in_time_zone(object.account.get_time_zone), format: :time)).html_safe
    end

    def end_date
      if object.end_date
        (h.l(object.end_date.to_date) + "," +
          h.tag("br") +
          h.l(object.end_date.in_time_zone(object.account.get_time_zone), format: :time)).html_safe
      end
    end

    # get the date of the early signup deadline
    def early_signup_pricing
      if object.early_signup_pricing
        true
      else
        false
      end
    end
    def early_signup_deadline
      if object.early_signup_deadline
        (h.l(object.early_signup_deadline, format: :short) + "," +
          h.tag("br") +
          h.l(object.early_signup_deadline, format: :time)).html_safe
      else
        ""
      end
    end

    def early_signup_deadline_date
      if object.early_signup_deadline
        h.l(object.early_signup_deadline, format: :short).html_safe
      else
        ""
      end
    end

    def early_signup_deadline_time
      if object.early_signup_deadline
        h.l(object.early_signup_deadline, format: :time).html_safe
      else
        ""
      end
    end

    def paymentmethods
      object.paymentmethods.with_translations(I18n.locale).pluck(:name)
    end

    def price
      if object.free?
        h.t(:free_of_charge)
      else
        h.money_to_currency(object.price)
      end
    end

    def full_price
      if object.free?
        h.t(:free_of_charge)
      else
        h.money_to_currency(object.full_price)
      end
    end

    def price_with_vat
      if object.free?
        h.t(:free_of_charge)
      else
        h.money_to_currency(object.price)
      end
    end

    def show_link
      h.link_to(object.name, h.signup_show_event_url(object, subdomain: subdomain))
    end

    def details_link
      h.link_to(h.signup_show_event_url(object, subdomain: subdomain), class: 'btn btn-default btn-sm btn-default event_btn_details') do
        h.t(:details)
      end
    end

    # show a signup button (i.e. a form) or a fully booked button or an external link in the json event list
    def signup_link
      if object.external_signup?
        h.content_tag(:form, method: 'get', action: h.signup_redirect_url(object, subdomain: subdomain)) do
          "#{adpartner_field}#{signup_button}".html_safe
        end
        # h.link_to(h.signup_redirect_url(object, subdomain: subdomain), class: 'btn btn-default btn-sm btn-warning event_btn_details') do
        #   h.t(:ectern)
        # end
      else
        if object.free_seats?
          h.content_tag(:form, method: 'post', action: h.signup_event_url(object, subdomain: subdomain)) do
            "#{adpartner_field}#{signup_button}".html_safe
          end
        else
          button_fully_booked
        end
      end
    end

    def button_fully_booked
      "<button disabled=\"disabled\" class=\"btn btn-warning event_btn_fully_booked\" id=\"#{object.class}-#{object.id}\">#{I18n.t(:fully_booked)}</button>".html_safe
    end

    def adpartner_field
      if adpartner_id.present?
        h.tag(:input, type: 'hidden', name: 'adpartner', value: adpartner_id)
      else
        ''
      end
    end

    def signup_button
      h.tag(:input, type: 'submit', class: 'btn btn-default btn-success event_btn_signup', value: h.t(:sign_up_now))
    end
  end
end
