# Service for manually creating an invoiceposition from an event

class InvoicepositionCreateFromEvent
  # initialize with businessdocument to create an new businessdocumentposition
  def initialize(businessdocument, event)
    @businessdocument = businessdocument.decorate
    @event = event.decorate
  end

  def perform
    # create the new invoiceposition
    event_name = @event.name
    if @event.start_date
      event_name = event_name + ' ' + @event.start_date.to_s
    end
    Billing::Businessdocumentposition.create({
      businessdocument: @businessdocument,
      name: event_name,
      description: ActionView::Base.full_sanitizer.sanitize(@event.shortdescription),
      amount: 1,
      price: @event.price,
      vat: @event.vat,
      product: @event
    })
  end

end
