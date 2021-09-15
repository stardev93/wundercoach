#task to generate paymentterms per account for one time use when migrating
namespace :wc do
  require Rails.root.join('app', 'services', 'account', 'account_setup_paymenterms.rb')
  desc "update prices to match price_cents"
  task :coaches_update_prices => :environment do

    puts 'Updating coach prices'
    sql = "UPDATE coaches SET coaches.price_cents = (coaches.price * 100)"
    ActiveRecord::Base.connection.execute(sql)

    # Coach.find_each do |coach|
    #   puts "Updating Coach: " + coach.lastname.to_s
    #   puts "coach.price: " + coach.price.to_s
    #
    #   coach.price_cents = coach.price * 100 unless coach.price.nil?
    #
    #   puts "coach.price_cents: " + coach.price_cents.to_s
    #   coach.save!
    # end
  end
end
