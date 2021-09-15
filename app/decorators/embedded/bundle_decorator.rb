module Embedded
  # provides context for a widget based on an event
  # make the replacings for javascript event lists
  class BundleDecorator < Draper::Decorator
    attr_accessor :adpartner_id

    def context
      {
        'name' => object.name,
        'shortdescription' => object.shortdescription,
        'longdescription' => object.longdescription,
        'bottom_text' => object.bottom_text,
        'text' => object.text,
        'start_date' => start_date,
        'end_date' => end_date,
        'slug' => object.slug,
        'price' => price,
        'show_link' => show_link,
        'details_link' => details_link,
        'signup_link' => signup_link,
      }
    end

    def subdomain
      object.account.subdomain
    end

    private

    def start_date
      if object.start_date
        h.l(object.start_date.to_date).html_safe
      end
    end

    def end_date
      if object.end_date
        h.l(object.end_date.to_date).html_safe
      end
    end

    def price
      if object.free?
        h.t(:free_of_charge)
      else
        h.money_to_currency(object.price)
      end
    end

    def show_link
      h.link_to(object.name, h.signup_show_bundle_url(object, subdomain: subdomain))
    end

    def details_link
      h.link_to(h.signup_show_bundle_url(object, subdomain: subdomain), class: 'btn btn-default btn-sm btn-default event_btn_details') do
        h.t(:details)
      end
    end

    def signup_link
      if object.bookable?
        h.content_tag(:form, method: 'post', action: h.signup_bundle_url(object, subdomain: subdomain)) do
          "#{adpartner_field}#{signup_button}".html_safe
        end
      else
        button_fully_booked
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
