# Used for sending account invoices to accounts customer for event participation
# uses send_composed_mail from CustomerMailer
# Required mailer: wundercoach standard mailer OR custom if is setup
#
# sent from
# app/models/event_handler.rb
# app/services/invoice/invoice_send.rb
class InvoiceMailer < CustomerMailer
  def send_to_customer(account, invoice, mailtemplate)
    attachments["#{invoice.get_pdf_filename}"] = File.read invoice.pdf.path

    # call the customer mailer
    send_composed_mail(account, invoice.order, mailtemplate, to: invoice.email)
  end
end
