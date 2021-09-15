# Service for cancelling an invoice
class InvoiceCancel

  # initialize with order object to create an new invoice
  def initialize(invoice)
    @invoice = invoice
  end

  def perform
    # @invoice.dup
    cancellation = Billing::Cancellation.new
    cancellation.next_document_number
    cancellation.assign_attributes({
      name: I18n.t(:cancellation_for, invoice_number: @invoice.invoice_number),
      order: @invoice.order,
      address: @invoice.address,

      recipient1: @invoice.recipient1,
      recipient2: @invoice.recipient2,
      recipient_name1: @invoice.recipient_name1,
      recipient_name2: @invoice.recipient_name2,
      recipient_street: @invoice.recipient_street,
      recipient_zip: @invoice.recipient_zip,
      recipient_city: @invoice.recipient_city,
      recipient_country: @invoice.recipient_country,
      recipient_email: @invoice.recipient_email,

      invoicetype: Billing::Invoicetype.find_by(key: 'cancellation'),
      type: 'Billing::Cancellation',
      predecessor: @invoice,
      pdf: nil,
      paymentstatus: Paymentstatus.find_by(key: 'open'),
      invoicestatus: Billing::Invoicestatus.find_by(key: 'new'),
      invoice_date: Date.today
    })

    @invoice.businessdocumentpositions.each do |cancelled_position|
      position = cancelled_position.dup
      position.price *= -1
      cancellation.businessdocumentpositions << position
    end
    cancellation.save!
    @invoice.cancelled = true
    @invoice.save
    return cancellation
  end

end
