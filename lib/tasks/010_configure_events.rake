namespace :wc do
  desc "Create standard events"
  task :configure_events => :environment do
    require 'populator'
    require 'faker'

    tag_names = Array.new(5) { Faker::Job.unique.key_skill }

    puts 'Configuring events for each account'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      puts ' '
      puts 'Configuring Events for: ' + account.name.to_s
      puts '---------------------------------------------------'

      paymentmethods = Paymentmethod.where(key: %w(banktransfer vorkasse)).to_a
      # tag_names = Array.new(5) { Faker::Job.key_skill }
      # Product::Tag.create(tag_names.map { |tag_name| {name: tag_name} })
      #
      # tags = Product::Tag.all.to_a

      Event.find_each do |event|
        event.paymentmethods << paymentmethods.sample
        # event.tags << tags.sample(2)
        event.save!
      end

    end
  end
end
