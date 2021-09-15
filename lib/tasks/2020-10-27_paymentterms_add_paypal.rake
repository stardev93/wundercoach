#task to generate paymentterms per account for one time use when migrating
namespace :wc do
  require Rails.root.join('app', 'services', 'account', 'account_setup_paymenterms.rb')
  desc "populate paymentterms for each account with paypal"
  task :paymentterms_add_paypal => :environment do

    puts 'Adding PayPal to account paymentterms'
    paypal_paymentmethod = Paymentmethod.find_by(key: "paypal")
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      puts " "
      puts account.name
      puts "---------------------"
      paymentterm = Paymentterm.find_by(paymentmethod_id: paypal_paymentmethod.id, context: 'checkout')
      unless paymentterm
        paymentterm = AccountSetupPaymenterms.new(ActsAsTenant.current_tenant).add_paymentterm(paypal_paymentmethod)
        puts paymentterm.to_s + ' added!'
      end

    end
  end
end
