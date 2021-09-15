namespace :wc do
  desc "Set businessdocument.recipient_email to @order.invoiceaddress.email"
  task :set_recipient_email => :environment do

    Billing::Businessdocument.find_each do |dbdoc|
      if dbdoc.order && dbdoc.order.invoice_address and !dbdoc.order.invoice_address.email.blank?
        puts dbdoc.order.invoice_address
        dbdoc.recipient_email = dbdoc.order.invoice_address.email
        dbdoc.save!
      else
        puts "no email found ============================================"
      end
    end

  end
end
