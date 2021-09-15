namespace :wc do
  desc "Extend invoices to hold all information required for application update"
  task :extend_invoices => :environment do

    Billing::Businessdocument.find_each do |dbdoc|
      puts dbdoc.class
      dbdoc.type = (dbdoc.invoicetype_id == 1 ? 'Billing::Invoice' : 'Billing::Cancellation')
      dbdoc.save!
    end

    Billing::Businessdocumentposition.find_each do |dbdocpos|
      puts dbdocpos.id
      dbdocpos.businessdocument_id = dbdocpos.invoice_id
      dbdocpos.save!
    end
  end
end
