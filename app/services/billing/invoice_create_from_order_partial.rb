# Service for creating an invoice from order in checkout dialogue
class InvoiceCreateFromOrderPartial

  # initialize with order object to create an new invoice
  def initialize(order, eventbooking)
    @order = order
    @eventbooking = eventbooking
  end

  def perform
    # create the new invoice. move this to invoice object or another better place.
    raise CannotInvoiceError, I18n.t(:cannot_invoice_free_product) if @order.free?

    new_address = @order.invoice_address.dup
    new_address.save!

    @invoice = Billing::Invoice.new({
      # set invoice text field recipient to address.company or to address.fullname of @order
      # what about billing_address?
      order: @order,
      recipient1: @order.invoice_address.company || @order.invoice_address.fullname,
      recipient_name1: @order.invoice_address.company || @order.invoice_address.fullname,
      recipient_name2: (@order.invoice_address.company ? @order.invoice_address.fullname : ''),
      recipient_street: @order.invoice_address.street,
      recipient_zip: @order.invoice_address.zip,
      recipient_city: @order.invoice_address.city,
      recipient_country: @order.invoice_address.country,
      recipient_email: @order.invoice_address.email,
      invoice_date: Time.zone.now,
      address: new_address,
      invoicestatus: Billing::Invoicestatus.find_by(key: 'new'),
      invoicetype: Billing::Invoicetype.find_by(key: 'invoice'),
      currency: @order.currency
    })

    @invoice.type = "Billing::Invoice"
    if @order.paid?
      @invoice.paymentstatus = Paymentstatus.find_by(key: 'paid')
      @invoice.paymentdate = Date.today
    else
      @invoice.paymentstatus = Paymentstatus.find_by(key: 'open')
    end
    @invoice.due_date = @order.product.reservation_expiry if @order.paymentmethod.key == 'vorkasse'
    #@invoice.next_document_number


    @invoice.invoice_date ||= Date.today

    # @invoice.document_freeze unless @invoice.frozen?

    if @invoice.invoice_number
      @invoice.name = I18n.t(:invoice) + ' ' + @invoice.invoice_number.to_s
    end
    @invoice.save!

    InvoicepositionCreateFromOrderPartial.new(@invoice, @order, @eventbooking).perform
    @invoice.save!

    return @invoice
  end

end

class InvoicepositionCreateFromOrderPartial

  # initialize with order object to create an new invoice
  def initialize(invoice, order, eventbooking)
    @order = order
    @invoice = invoice
    @eventbooking = eventbooking
  end

  def perform
    # create the new invoiceposition
    new_businessdocumentposition = Billing::Businessdocumentposition.create({
      businessdocument_id: @invoice.id,
      name: @eventbooking.event.name + ' ' + @eventbooking.event.decorate.start_date.to_s,
      amount: (@order.amount.blank? ? 1 : @order.amount),
      price: @order.price,
      vat: @order.vat,
      order: @order,
      product: @eventbooking.event,
      eventbooking: @eventbooking
    })
    # @eventbooking.businessdocumentposition_id = new_businessdocumentposition.id
    # @eventbooking.save!

    if new_businessdocumentposition.businessdocument.order && new_businessdocumentposition.businessdocument.order.eventbookings.first && new_businessdocumentposition.businessdocument.order.eventbookings.first.address
      new_businessdocumentposition.description = new_businessdocumentposition.businessdocument.order.eventbookings.first.address.decorate.full_address
      new_businessdocumentposition.save!
    end
  end

end
