class EventHandler
  include Singleton

  # process method calls event with flexible number of arguments
  # may raise no method error
  def process(event, *args)
    send event, *args
  end

  # Events

  # find my now in EventbookingService.cancel_eventbooking
  # Send Cancellation Mail, create Cancellation Invoices if necessary
  # def booking_cancelled(eventbooking)
  #   eventbooking.eventbookingstatus = Eventbookingstatus.find_by(key: 'cancelled')
  #   # mailtemplate = Mailtemplate.find_by key: 'booking_cancellation_email'
  #   # send_default_event_mail(eventbooking, mailtemplate)
  #   eventbooking.save
  # end

  # Send Request to both the customer and the coach
  def request_sent(request)
    mailtemplate = Mailtemplate.find_by key: 'request_email'
    EventMailer.send_composed_mail(mailtemplate.account,
      request,
      mailtemplate,
      to: [request.email, request.event.account.email]
    ).deliver_later
  end

  # send an invoice from account for booked event
  def send_invoice(invoice)
    # search for systems invoice template
    mailtemplate = Mailtemplate.find_by key: 'invoice_email'

    # call the invoice mailer
    InvoiceMailer.send_to_customer(invoice.account, invoice, mailtemplate).deliver_later
  end

  private

  def send_default_event_mail(eventbooking, mailtemplate)
    EventMailer.send_composed_mail(eventbooking.account,
                                   eventbooking,
                                   mailtemplate,
                                   to: eventbooking.email).deliver_later
  end
end
