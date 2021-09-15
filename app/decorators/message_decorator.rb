class MessageDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def get_body_teaser
    return h.truncate(h.strip_tags(object.body), length: 250)
  end

  def body
    return object.body
  end

  def published_at(timezone)
    h.l object.published_at.in_time_zone(timezone), format: :default if object.published_at
  end

  def published_at_date(timezone)
    h.l object.published_at.in_time_zone(timezone), format: :short if object.published_at
  end

  def published_at_time(timezone)
    h.l object.published_at.in_time_zone(timezone), format: :time if object.published_at
  end

  def pushed_at(timezone)
    h.l object.pushed_at.in_time_zone(timezone), format: :default if object.pushed_at
  end

  def pushed_at_date(timezone)
    h.l object.pushed_at.in_time_zone(timezone), format: :short if object.pushed_at
  end

  def pushed_at_time(timezone)
    h.l object.pushed_at.in_time_zone(timezone), format: :time if object.pushed_at
  end

end
