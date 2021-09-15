namespace :wc do
  desc "Set new field vat_net_first to false for each account"
  task :set_account_autonumbering => :environment do

    Account.find_each do |account|
      puts account
      account.account_receivable_autonumbering = false
      account.account_receivable_no_start = 10000
      account.save!
    end
  end
end
