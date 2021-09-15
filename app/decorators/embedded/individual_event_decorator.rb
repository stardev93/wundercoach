module Embedded
  # provides context for a widget based on an event
  # make the replacings for javascript event lists
  class IndividualEventDecorator < Draper::Decorator
    attr_accessor :adpartner_id

    def context
      {
        'bottom_text' => object.bottom_text,
        'city' => object.city,
        'country' => object.country,
        'eventorganizer' => object.eventorganizer,
        'location' => object.location,
        'longdescription' => object.longdescription,
        'maxparticipants' => object.maxparticipants,
        'name' => object.name,
        'price' => price,
        'shortdescription' => object.shortdescription,
        'street' => "#{object.street} #{object.streetno}",
        'zip' => object.zip,
        'coaches' => object.coaches.join('<br>'),
        'show_link' => show_link,
        'details_link' => details_link,
        'request_link' => request_link,
        'signup_link' => signup_link,
        'paymentmethods' => paymentmethods,
        'account' => object.account.name
      }
    end

    def subdomain
      object.account.subdomain
    end

    private

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

    def show_link
      h.link_to(object.name, h.signup_show_event_url(object, subdomain: subdomain))
    end

    def details_link
      h.link_to(h.signup_show_event_url(object, subdomain: subdomain), class: 'btn btn-default btn-sm btn-warning event_btn_details') do
        h.t(:details)
      end
    end

    def signup_link
      if object.external_signup?
        h.content_tag(:form, method: 'get', action: h.signup_redirect_url(object, subdomain: subdomain)) do
          "#{adpartner_field}#{signup_button}".html_safe
        end
        # h.link_to(h.signup_redirect_url(object, subdomain: subdomain), class: 'btn btn-default btn-sm btn-warning event_btn_details') do
        #   h.t(:ectern)
        # end
      else
        h.content_tag(:form, method: 'post', action: h.signup_event_url(object, subdomain: subdomain)) do
          "#{adpartner_field}#{signup_button}".html_safe
        end
      end
    end

    def request_link
      h.link_to I18n.t(:send_request), h.signup_new_request_url(object), class: "btn btn-sm btn-default btn-primary event_btn_signup", style: "width:100%;"
    end

    def adpartner_field
      if adpartner_id.present?
        h.tag(:input, type: 'hidden', name: 'adpartner', value: adpartner_id)
      else
        ''
      end
    end

    def signup_button
      h.tag(:input, type: 'submit', class: 'btn btn-default btn-success btn-lg event_btn_signup', value: h.t(:sign_up_now))
    end
  end
end
