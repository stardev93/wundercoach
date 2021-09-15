module Embedded
  # provides a context for embedding all events on a customer's website,
  # using jsonp
  class AccountDecorator < Draper::Decorator
    def context(filters = {})
      {
        'name' => object.name,
        'events' => object.events.filter(filters).no_eventtemplates.by_start_date.public_events.online_events.distinct.map {|event| EventDecorator.new(event).context },
        'bundles' => object.events.filter(filters).no_eventtemplates.bundle_events.by_start_date.public_events.online_events.distinct.map {|event| EventDecorator.new(event).context },
        'individual_events' => object.individual_events.filter(filters).online.distinct.map {|individual_event| IndividualEventDecorator.new(individual_event).context },
        'style' => style,
        'stylesheet' => stylesheet
      }
    end

    private

    def style
      object.css_code
    end

    def stylesheet
      h.content_tag(:style) { style }
    end
  end
end
