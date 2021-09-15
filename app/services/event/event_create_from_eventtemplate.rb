# Add a new Event from Eventtemplate
# EventCreateFromEventtemplate.new(eventtemplate).perform
class EventCreateFromEventtemplate

  # initialize with invoice object to send an invoice
  def initialize(eventtemplate)
    @eventtemplate = eventtemplate
  end

  def perform

    event_params =
      @eventtemplate
      .attributes
      .reject {|key, _value| %w(id coach_id created_at updated_at make_public meta_title meta_description meta_keywords use_tracking max_additional_participants type).include? key }
      .merge name: @eventtemplate.name,
             onlinestatus: Onlinestatus.find_by(key: 'offline'),
             planningstatus: Planningstatus.find_by(key: 'not_planned'),
             vat: Vat.find_by(key: 'regular_vat') # TODO: Add VAT field to eventtemplate and copy it to event instead of setting a default here
    @event =
      if @eventtemplate.price.zero?
        FreeEvent.new(event_params)
      else
        Event.new(event_params)
      end
    @event.product_tags << @eventtemplate.product_tags
    @event.eventtemplate_id = @eventtemplate.id
    @event.add_paymentmethods
    @event.max_additional_participants = 0
    @event.save!

    return @event
  end




end
