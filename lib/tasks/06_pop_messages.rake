namespace :wc do
  desc "Create shared demo messages for system"
  task :pop_messages => :environment do
    require 'populator'
    require 'faker'

    Usermessage.delete_all
    Message.delete_all
    puts 'Populating messages for all accounts'

    I18n.locale = :de
    message = Message.new
    message.subject = "DE - Neue Nachricht 1"
    message.body = "DE " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.pushed_at = Time.now
    message.published_at = Time.now
    message.save

    I18n.locale = :en
    message.subject = "EN - New message 1"
    message.body = "EN " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.save

    I18n.locale = :de
    message = Message.new
    message.subject = "DE - Neue Nachricht 2"
    message.body = "DE " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.pushed_at = Time.now + 1.day
    message.published_at = Time.now + 1.day
    message.save

    I18n.locale = :en
    message.subject = "EN - New message 2"
    message.body = "EN " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.save

    I18n.locale = :de
    message = Message.new
    message.subject = "DE - Neue Nachricht 3"
    message.body = "DE " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.pushed_at = Time.now + 2.days
    message.published_at = Time.now + 2.days
    message.save

    I18n.locale = :en
    message.subject = "EN - New message 3"
    message.body = "EN " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.save

    I18n.locale = :de
    message = Message.new
    message.subject = "DE - Neue Nachricht 4"
    message.body = "DE " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.pushed_at = Time.now - 2.days
    message.published_at = Time.now - 2.days
    message.save

    I18n.locale = :en
    message.subject = "EN - New message 4"
    message.body = "EN " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.save

    I18n.locale = :de
    message = Message.new
    message.subject = "DE - Neue Nachricht 5"
    message.body = "DE " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.pushed_at = Time.now - 2.days
    message.published_at = Time.now - 2.days
    message.save

    I18n.locale = :en
    message.subject = "EN - New message 5"
    message.body = "EN " + Faker::Lorem.paragraph(10, sentence_count=10)
    message.save


    puts 'Done populating messages'

    puts 'Activating display in user accounts'
    User.find_each do |user|
      puts user
      user.has_message = true
      user.save!
    end
  end
end
