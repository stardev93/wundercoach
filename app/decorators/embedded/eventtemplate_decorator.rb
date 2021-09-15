module Embedded
  # provides a context for embedding an eventtemplate on a customer's website,
  # using jsonp
  class EventtemplateDecorator < Draper::Decorator
    delegate_all
    def context
      {
        'eventtemplate' => object.attributes,
        'name' => object.name,
        'events' => object.events.upcoming.map {|event| EventDecorator.new(event).context },
        'style' => style,
        'stylesheet' => stylesheet
      }
    end

    def price
      if object.price.present?
        h.money_to_currency(object.price)
      end
    end

    private

    def style
      object.account.css_code
    end

    def stylesheet
      h.content_tag(:style) { style }
    end
  end
end
