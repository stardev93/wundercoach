# Service for creating an eventbooking from an order
class EventbookingService

  # initialize with order object to create an new invoice
  def initialize
    # @order = order
    # @product = order.product
  end

  # create a new eventbooking for order
  def book_event(order)
    @order = order
    @product = order.product
    # create an eventbooking for @product (event)

    # BundleEvent: create eventbookings for subevents
    if @product.type == "BundleEvent"
      @eventbooking = create_eventbooking(@order, @product)
      @product.subevents.each do |bundled_event|
        create_eventbooking(@order, bundled_event.subevent)
      end
    else
      @eventbooking = create_eventbooking(@order, @product)
    end

    @order.save
    @eventbooking.save
    return @eventbooking
  end

  # assign status "cancelled"
  def cancel_eventbooking(eventbooking)
    @order = eventbooking.order

    eventbooking.eventbookingstatus = Eventbookingstatus.find_by(key: 'cancelled')
    eventbooking.save

    if eventbooking.event&.type == "BundleEvent"
      @order.eventbookings.no_bundles.each do |subeventbooking|
        cancel_eventbooking(subeventbooking)
      end
    end

    # mailtemplate = Mailtemplate.find_by key: 'booking_cancellation_email'
    # send_default_event_mail(eventbooking, mailtemplate)

    return eventbooking
  end

  def create_eventbooking(order, event)
    # event.eventbookings.create!({
    #   address: order.address,
    #   billing_address: order.billing_address,
    #   eventbookingstatus: Eventbookingstatus.find_by(key: 'confirmed'),
    #   booking_date: Time.now,
    #   order: order,
    #   additional_data: order.additional_data
    # })
    eventbooking = Eventbooking.create!({
      event: event,
      address: order.address,
      billing_address: order.billing_address,
      eventbookingstatus: Eventbookingstatus.find_by(key: 'confirmed'),
      booking_date: Time.now,
      order: order,
      additional_data: order.additional_data
    })
    return eventbooking
  end
end
