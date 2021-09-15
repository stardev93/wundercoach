# Duplicate an Event
# return EventDuplicate.new(event).perform
class EventDuplicate

  # initialize with invoice object to send an invoice
  def initialize(event)
    @event = event
  end

  def perform
    # ToDo: add relations to deep_clone: :eventfields, :eventfieldvalues
    @new_event = @event.deep_clone include: [:paymentmethods, :product_taggings]
    @new_event.name = @new_event.name + " (#{I18n.t(:record_copy)})"
    @new_event.onlinestatus = Onlinestatus.find_by key: 'offline'
    @new_event.planningstatus = Planningstatus.find_by key: 'not_planned'

    if @new_event.max_additional_participants.nil?
      @new_event.max_additional_participants = 0
    end
    # currently we do not allow additional_participants in non-free events
    if @new_event.additional_participants? && (!@event.free? or @event.price_early_signup_cents&.positive?)
      @new_event.max_additional_participants = 0
    end
    # if type
    @new_event.save!
    return @new_event
  end

end
