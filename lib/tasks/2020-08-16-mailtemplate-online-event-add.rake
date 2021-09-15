namespace :wc do
  desc "Add new mailtemplate for online events"
  task :add_mailtemplate_online_events => :environment do

    puts 'Creating mailtemplate for each account'
    puts '-------------------------------------'
    Mailtemplate.where(key: 'booking_confirmation_email_online_event').delete_all
    Account.all.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id
      puts "Acount: " + account.id.to_s + ' - ' + account.name.to_s
      puts '---------------------------'

        unless Mailtemplate.find_by key: 'booking_confirmation_email_online_event'
          I18n.locale = :de
          mailtemplate = Mailtemplate.new

          mailtemplate.mailskin_id = Mailskin.all.first.id
          mailtemplate.key = "booking_confirmation_email_online_event"
          mailtemplate.is_system = true

          mailtemplate.name = "Anmeldebestätigung Online-Seminar"
          mailtemplate.subject = "Ihre Anmeldung für das Online-Seminar {event.name}"
          mailtemplate.message = "{eventbooking.salutation} {eventbooking.lastname},<br /><br />Sie haben sich erfolgreich für das Seminar {event.name} angemeldet. Das Seminar findet am {event.startdate} um {event.starttime} als Online-Seminar statt.<br /><br />Bitte benutzen Sie diesen Link {event.webinar_url}, um an der Veranstaltung mit {event.webinar_provider} teilzunehmen.<br /><br />Der Benutzername lautet: {event.webinar_username} / Passwort: {event.webinar_pw}<br /><br />Hilfe bei der Anmeldung erhalten Sie unter {event.webinar_help_url} <br /><br />Mit herzlichen Grüssen<br /><br />{user.firstname}﻿ {user.lastname}﻿<br />"

          mailtemplate.save!

          I18n.locale = :en
          mailtemplate.name = "Signup confirmation online seminar"
          mailtemplate.subject = "Your signup confirmation for the online seminar {event.name}"
          mailtemplate.message = "{eventbooking.salutation} {eventbooking.lastname},<br /><br />You have registered successfully for th online seminar {event.name}. The seminar is scheduled to take place on {event.startdate} at {event.starttime} as an online seminar.<br /><br />Please follow this link {event.webinar_url} to signup with {event.webinar_provider}.<br /><br />Your username is: {event.webinar_username} / Password: {event.webinar_pw}<br /><br />Help can be found here {event.webinar_help_url}<br /><br />Best regards<br /><br />{user.firstname}﻿ {user.lastname}﻿<br />"

          mailtemplate.save!
          puts "Mailtemplate created"
        else
          puts "Mailtemplate with key booking_confirmation_email_online_event exists"
        end
      end

  end
  puts 'Done creating online event mailtemplates'
end
