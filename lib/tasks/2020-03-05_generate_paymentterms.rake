#task to generate paymentterms per account for one time use when migrating
namespace :wc do
  require Rails.root.join('app', 'services', 'account', 'account_setup_paymenterms.rb')
  desc "generate paymentterms for each account"
  task :generate_paymentterms => :environment do

    puts 'Generating paymentterms'
    Paymentterm.delete_all
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      puts " "
      puts account.name
      puts "---------------------"

      AccountSetupPaymenterms.new(account).perform

    end
  end
end
