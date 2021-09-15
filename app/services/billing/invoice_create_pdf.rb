# Service for creating an invoice from order
class InvoiceCreatePdf

  # initialize with invoice object to send an invoice
  def initialize(businessdocument)
    @businessdocument = businessdocument
  end

  def perform
    if @businessdocument.pdf && !@businessdocument.pdf.path.nil?
      if File.exist?(@businessdocument.pdf.path)
        File.delete(@businessdocument.pdf.path)
      end
    end
    # document_freeze first to get a new invoice number
    unless @businessdocument.frozen?
      @businessdocument.document_freeze
    end

    # create the invoice pdf file
    global_options = { layout: 'pdf.html', locals: { :@businessdocument => @businessdocument } }
    tmp_dir = Rails.root.join('tmp', 'invoices', @businessdocument.account.id.to_s)
    tmp_path = Rails.root.join(tmp_dir, @businessdocument.get_pdf_filename)
    Dir.mkdir(tmp_dir) unless File.exists?(tmp_dir)

    generator = ::PdfGenerator.new(
      ['billing/businessdocuments/pdf/pdf.html', global_options],
      @businessdocument.pdf_options,
      tmp_path
    )
    generator.footer_html_options = ['billing/businessdocuments/pdf/footer.html', global_options]
    generator.header_html_options = ['billing/businessdocuments/pdf/header.html', global_options]
    generator.create_pdf

    @businessdocument.pdf = File.open(tmp_path)
    @businessdocument.save!

    File.delete(tmp_path) if File.exist?(tmp_path)

    # set the businessdocument status for printed / sent or both
    new_status = @businessdocument.invoicestatus.key == 'sent' ? 'printed_and_sent' : 'printed'
    @businessdocument.invoicestatus = Billing::Invoicestatus.find_by(key: new_status)
    @businessdocument.save!

    return @businessdocument
  end

end
