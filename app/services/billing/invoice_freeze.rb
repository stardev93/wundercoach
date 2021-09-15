# Service for freezing an invoice
# sets an invoice number
# invoices with invoice_number are frozen
class InvoiceFreeze

  def initialize(businessdocument)
    @businessdocument = businessdocument
  end

  def perform
    # get next number and save document
    if @businessdocument.invoice_number.blank?
      @businessdocument.next_document_number
      @businessdocument.save!
    end

    return @businessdocument
  end

end
