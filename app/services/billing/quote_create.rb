# Service for manually creating an invoice for a contact
class QuoteCreate

  # initialize with contact_address object to create an new invoice
  def initialize(contact_address)
    @contact_address = contact_address
    @contact = contact_address.contact
  end

  def perform

    @businessdocument = Billing::Quote.new

    @businessdocument.invoicestatus = Billing::Invoicestatus.find_by(key: "new")
    @businessdocument.invoicetype = Billing::Invoicetype.find_by(key: "invoice")
    @businessdocument.paymentstatus = Paymentstatus.find_by(key: "open")

    @businessdocument.contact_address = @contact_address
    @businessdocument.contact = @contact

    if @contact.type == "Company"
      @businessdocument.recipient_name1 = @contact.name.to_s
      @businessdocument.recipient_name2 = @contact.name2.to_s
      #@businessdocument.recipient_person = @contact.firstname + ' ' + @contact.lastname
    else
      @businessdocument.recipient_name1 = @contact.firstname.to_s
      @businessdocument.recipient_name2 = @contact.lastname.to_s
    end

    @businessdocument.recipient_street = @contact_address.street.to_s
    @businessdocument.recipient_zip = @contact_address.zip.to_s
    @businessdocument.recipient_city = @contact_address.city.to_s
    @businessdocument.recipient_country = @contact_address.country

    @businessdocument.invoice_date = Date.today
    @businessdocument.currency = @contact.account.default_currency_iso_code || 'EUR'

    @businessdocument.due_date = Date.today
    @businessdocument.account_receivable_no = @contact.account_receivable_no
    @businessdocument.contact_no = @contact.contact_no

    @businessdocument.invoice_date ||= Date.today
    if @businessdocument.invoice_number
      @businessdocument.name = I18n.t(:invoice) + ' ' + @businessdocument.invoice_number.to_s
    end

    @businessdocument.save!

    # create invoice pdf file
    # NO- we don't do that here. Creating the pdf leads to frozen businessdocuments that cannot be edited
    # @businessdocument.delay.create_pdf

    return @businessdocument
  end

end
#
#
# class InvoicepositionCreateFromEvent
#   # initialize with event object to create an new businessdocumentposition
#   def initialize(businessdocument, event)
#     @businessdocument = businessdocument
#     @event = event
#   end
#
#   def perform
#     # create the new invoiceposition
#     Billing::Businessdocumentposition.create({
#       businessdocument: @businessdocument,
#       name: @event.name + ' ' + (I18n.l @event.start_date, format: :short).to_s,
#       description: @event.shortdescription,
#       amount: 1,
#       price: @event.price,
#       vat: @event.vat
#     })
#   end
#
# end
