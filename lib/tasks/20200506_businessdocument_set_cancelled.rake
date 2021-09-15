#task to populate new field cancelled for cancelled invoices
namespace :wc do
  desc "set new field cancelled for invoices"
  task :businessdocument_set_cancelled => :environment do

    puts 'Updating businessdocument set canceeld = true if cancelled'

    Billing::Businessdocument.all.each do |businessdocument|
      # check if we have a successor
      successor = businessdocument.get_successor
      if !successor.nil? && successor.type == "Billing::Cancellation"
        puts "Updating businessdocument: " + businessdocument.invoice_number.to_s
        puts "businessdocument.get_successor: " + successor.to_s
        businessdocument.cancelled = true
        businessdocument.save
      end
    end
  end
end
