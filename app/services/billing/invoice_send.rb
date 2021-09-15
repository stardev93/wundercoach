# Service for sending an invoice from account to a client
# merging should be a separate service (SoC separation of concerns)
# See This https://hackernoon.com/service-objects-in-ruby-on-rails-and-you-79ca8a1c946e
# and this improved version https://hackernoon.com/going-further-with-service-objects-in-ruby-on-rails-b8aac13a7271
# SendInvoice.new({invoice: invoice}).perform
class InvoiceSend

  # initialize with invoice object to send an invoice
  def initialize(businessdocument)
    @businessdocument = businessdocument
    @account = @businessdocument.account
    # @order = @businessdocument.order
    # @eventbookings = @order.eventbookings
    @mailtemplate = Mailtemplate.find_by key: 'invoice_email'
  end

  def perform

    # document_freeze first to get a new invoice number
    unless @businessdocument.frozen?
      @businessdocument.document_freeze
    end

    # generate the pdf if it doesn't exist
    @businessdocument.create_pdf
    # unless @businessdocument.pdf_exists?

    InvoiceMailer.send_to_customer(@account, @businessdocument, @mailtemplate).deliver_later

    return @businessdocument
  end

  private

end
