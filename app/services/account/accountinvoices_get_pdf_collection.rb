class AccountinvoicesGetPdfCollection

  # initialize with invoice object to send an invoice
  def initialize(accountinvoices)
    @accountinvoices = accountinvoices
  end

  def perform
    pdf_collection = {}
    i = 1
    @accountinvoices.each do |accountinvoice|
      pdf_collection["#{accountinvoice.invoice_date.to_s + '-' + accountinvoice.id.to_s + '-' + File.basename(accountinvoice.pdf.path)}"] = accountinvoice.pdf.path unless accountinvoice.pdf.path.nil?
      # pdf_collection["#{i.to_s + '.pdf'}"] = accountinvoice.pdf.path unless accountinvoice.pdf.path.nil?
      i = i + 1
      # pdf_collection << accountinvoice.pdf.path
    end
    return pdf_collection
  end
end
