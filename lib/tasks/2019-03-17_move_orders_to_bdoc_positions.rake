# not sure if I should use this
namespace :wc do
  desc "Move order object from businessdocuments to businessdocumentpositions"
  task :move_orders => :environment do

    Billing::Businessdocument.find_each do |dbdoc|
      puts dbdoc.id
      if dbdoc.order && dbdoc.businessdocumentpositions.first && !dbdoc.businessdocumentpositions.first.order
        dbdoc.businessdocumentpositions.first.order = dbdoc.order
        dbdoc.businessdocumentpositions.first.save!
        puts "Saved:" + dbdoc.order.id.to_s
      end
    end

  end
end
