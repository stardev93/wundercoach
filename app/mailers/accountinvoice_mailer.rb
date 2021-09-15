class AccountinvoiceMailer < WcoachMailer
  # send wundercoach invoice to account

  layout 'accountinvoice_mailer'

  # sent from
  # app/controllers/admin/accountinvoices_controller.rb
  # app/services/invoice/invoice_send.rb
  def send_invoice(accountinvoice)
    attachments["#{accountinvoice}.pdf"] = File.read accountinvoice.pdf.path.to_s
    @accountinvoice = accountinvoice
    @account = @accountinvoice.account
    @subject = t(:your_wundercoach_invoice)

    mail to: @account.email_billing_address,
         subject: @subject,
         partial: @partial,
         bcc: 'go@wundercoach.net'
  end
end
