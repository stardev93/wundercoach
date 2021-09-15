class FilterDecorator < Draper::Decorator
  delegate_all

  def to_text
    case model.class.name
    when "PriceFilter"
      I18n.t(:participated_in_an_event_where_price_was_x, comparator: I18n.t(model.comparator), price: h.money_to_currency(model.price))
    when "LocationFilter"
      I18n.t(:participated_in_an_event_close_to_x, distance: model.distance, location: model.location)
    when "CampaignFilter"
      I18n.t(:participated_in_campaign_x, campaign: model.campaign)
    when "TypeFilter"
      I18n.t(:participated_in_an_event_where_eventtype_was_x, eventtype: model.eventtype)
    else
      I18n.t(:unknown_filter)
    end
  end
end
