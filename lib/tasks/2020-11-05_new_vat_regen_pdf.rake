namespace :wc do
  desc "Regenerate PDFs for wrong Vat accountinvoices"
  task :new_vat_regen_pdf => :environment do


    puts 'Regenerating PDFs in Accountinvoices'
    Accountinvoiceposition.where("start_date >= '2020-07-01'").each do |accountinvoiceposition|
      puts 'Updating Accountinvoice: ' + accountinvoiceposition.accountinvoice.invoice_number.to_s

      accountinvoiceposition.accountinvoice.create_pdf
      accountinvoiceposition.accountinvoice.save
    end
  end
end
