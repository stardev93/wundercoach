namespace :wc do
  desc "Set new field vat_net_first to false for each account"
  task :set_vat_net_first => :environment do

    Account.find_each do |account|
      puts account
      account.vat_net_first = false
      account.save!
    end
  end
end
