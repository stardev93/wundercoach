namespace :wc do
  desc "Create events and related objects for each account"
  task :pop_eventtags => :environment do
    require 'populator'
    require 'faker'

    # Not working for whatever reason:
    # ActiveRecord::StatementInvalid: Mysql2::Error: Table 'wundercoach.eventtemplate_taggings' doesn't exist: SHOW FULL FIELDS FROM `eventtemplate_taggings`
    # Product::Tagging.destroy_all
    # Product::Tag.destroy_all
    tag_names = Array.new(10) { Faker::Job.key_skill }

    puts 'Populating eventtags for each account and assign them'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      puts ' '
      puts 'Generating Tags for: ' + account.name.to_s
      puts '---------------------------------------------------'

      Product::Tag.create(tag_names.map { |tag_name| {name: tag_name} })

      tags = Product::Tag.all.to_a

      Event.find_each do |event|
        event.product_tags << tags.sample(4)
      end

    end
  end
end
