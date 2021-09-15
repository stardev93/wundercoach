namespace :wc do
  desc "Create events and related objects for each account"
  task :pop_eventtypes => :environment do
    require 'populator'
    require 'faker'

    # Not working for whatever reason:
    # ActiveRecord::StatementInvalid: Mysql2::Error: Table 'wundercoach.eventtemplate_taggings' doesn't exist: SHOW FULL FIELDS FROM `eventtemplate_taggings`
    Eventtype.destroy_all

    # Faker::Config.locale = 'en'

    # eventtype_names = Array.new(5) { Faker::Job.unique.key_skill }

    puts 'Populating Eventtypes for each account and assign them'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      puts ' '
      puts 'Generating Eventtype for: ' + account.name.to_s
      puts '---------------------------------------------------'

      #Eventtype.create(eventtype_names.map { |eventtype_name| {name: eventtype_name} })
      # Eventtype.populate 20 do |eventtype|
      #   eventtype.account_id = i
      #   eventtype.key = Faker::Job.key_skill
      #   eventtype.colorcode = '#999999'
      #   eventtype.locale = 'de'
      #   eventtype.name = Faker::Job.key_skill
      # end
      Faker::UniqueGenerator.clear
      10.times do |j|
        Eventtype.create([
          {
            account_id: i,
            key: Faker::Job.key_skill,
            colorcode: Faker::Color.hex_color,
            name: Faker::Job.key_skill,
            locale: "de"
          }
        ])
      end
      Eventtype.all.each do |eventtype|
        puts "Eventtype: " + eventtype.to_s
      end
      offset = rand(Eventtype.count)
      puts "Assigning Eventtype: " + Eventtype.offset(offset).first.to_s
      Event.find_each do |event|
        # event.eventtype = eventtypes.sample(1)
        event.eventtype = Eventtype.first
        event.save
      end

    end
  end
end
