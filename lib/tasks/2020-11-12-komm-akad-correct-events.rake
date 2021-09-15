# ToDo
# add col Bundesland_short to XLSX file after Bundesland (Col D)
# export file to csv with numbers
# Set path for filename
# remove column header from csv
# call be rake wc:importevents
require 'csv'

namespace :wc do
  desc "Correct events for Kommunalakademie with wrong duration"

  task kommunalakad_correctevents: :environment do

    # which timezone are the dates we are reading
    Time.zone = "Europe/Berlin"
    account = Account.find(1458)
    i = 1
    ActsAsTenant.with_tenant(account) do
      Event.where("name='Crashkurs Verwaltungsrecht in 3 Tagen – ein Crashkurs nicht nur für Quereinsteigerinnen und Quereinsteiger' AND type<>'Eventtemplate' and start_date > '2020-12-31'").each do |event|
        puts "Processing event no.:" + i.to_s
        puts "Start: " + event.start_date.to_s
        puts "End before: " + event.end_date.to_s


        event.end_date = event.end_date + 2.days
        event.duration = 3
        event.durationunit_id = 2
        event.save
        puts "End after: " + event.end_date.to_s

        i = i + 1
      end

      Event.where("name='Grundlagenkurs Steuerrecht – ein Crashkurs (3 Tage)' AND type<>'Eventtemplate' and start_date > '2020-12-31'").each do |event|
        puts "Processing event no.:" + i.to_s
        puts "Start: " + event.start_date.to_s
        puts "End before: " + event.end_date.to_s


        event.end_date = event.end_date + 2.days
        event.duration = 3
        event.durationunit_id = 2
        event.save
        puts "End after: " + event.end_date.to_s

        i = i + 1
      end


    end
    puts i.to_s + " Events corrected"
  end

end
