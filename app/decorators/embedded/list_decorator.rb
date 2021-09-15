module Embedded
  # provides a context for embedding an event_list on an adpartner's website,
  # using jsonp
  class ListDecorator < Draper::Decorator
    attr_accessor :adpartner_id
    def context
      {
        'name' => object.name,
        'events' => object.events.upcoming.map(&method(:event_context)),
        'style' => style,
        'stylesheet' => stylesheet
      }
    end

    private

    def event_context(event)
      event_decorator = EventDecorator.new(event)
      event_decorator.adpartner_id = adpartner_id
      event_decorator.context
    end

    # TODO: Enable adding styles
    def style
      '/* empty */'
      # object.account.css_code
    end

    def stylesheet
      h.content_tag(:style) { style }
    end
  end
end
