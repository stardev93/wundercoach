namespace :wc do
  desc "Set correct VAT for wrong Vat accountinvoices"
  task :new_vat_16perc => :environment do

    Vat.find_by(key: 'regular_vat_reduced')&.delete
    Vat.find_by(key: 'reduced_vat_reduced')&.delete

    puts 'Creating 16% and 5% VAT rates'

    I18n.locale = :de
    vat = Vat.new
    vat.key = "regular_vat_reduced"
    vat.value = 0.16
    vat.position = 2
    vat.vat_country_id = 1
    vat.name = 'MwSt. 16,00%'
    vat.save

    I18n.locale = :en
    vat.name = 'VAT 16,00%'
    vat.save

    I18n.locale = :de
    vat = Vat.new
    vat.key = "reduced_vat_reduced"
    vat.value = 0.05
    vat.position = 3
    vat.vat_country_id = 1
    vat.name = 'MwSt. 5,00%'
    vat.save

    I18n.locale = :en
    vat.name = 'VAT 5,00%'
    vat.save


    puts 'Done creating VAT entries'

    puts 'Updating VAT in Accountinvoicepositions'
    Accountinvoiceposition.where("start_date >= '2020-07-01' AND vat >= 0.18").each do |accountinvoiceposition|
      puts 'Updating Accountinvoiceposition: ' + accountinvoiceposition.accountinvoice.invoice_number.to_s
      accountinvoiceposition.vat = 0.16
      accountinvoiceposition.save
      # accountinvoiceposition.accountinvoice.create_pdf
    end
  end
end
