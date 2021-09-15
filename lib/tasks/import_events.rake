# ToDo
# add col Bundesland_short to XLSX file after Bundesland (Col D)
# export file to csv with numbers
# Set path for filename
# remove column header from csv
# call be rake wc:importevents
require 'csv'

namespace :wc do
  desc "Import events from csv"

  task importevents: :environment do

    filename = File.join Rails.root, "misc/kommunalakademie/2020-11-17_Import_18112020_TierschutzR.csv"
    counter = 0
    account_id = 1
    # CSV.foreach(filename) do |row|
    events = CSV.read(filename, col_sep: ';')

    # Event::Tagging.all.where("account_id=1458").delete_all
    # Event.all.where("account_id=1458").delete_all

    #results = ActiveRecord::Base.connection.execute("DELETE FROM events WHERE account_id=1458 AND type != 'Eventtemplate'")
    # results = ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")
    # results = ActiveRecord::Base.connection.execute("DELETE event_taggings, events FROM event_taggings INNER JOIN events ON event_taggings.event_id = events.id WHERE events.account_id=1458 AND events.type != 'Eventtemplate'")

    puts 'Importing events...'
    puts '---------------------------------------------'
    i = 0
    event_data = events.map do |event_arr|
      # 0;        1;        2;    3;      4;          5;                6;    7;      8;      9;          10;       11;           12;               13;                       14
      # Seminar;  Event_id; Tags; Region; Bundesland; Bundesland_short; Ort;  Datum;  Dauer;  start_date; end_date; Location ID;  full_price_cents; price_early_signup_cents; early_signup_deadline
      # SELECT *  FROM `events` WHERE `account_id` = 1458 AND `type` NOT LIKE 'Eventtemplate' ORDER BY `events`.`id` ASC
      # DELETE FROM events WHERE account_id=1458 AND type != 'Eventtemplate'
      # UPDATE events SET vat_id=2, durationunit_id=2 WHERE account_id=1458
      puts event_arr[0]
      puts event_arr[9]
      puts event_arr[10]
      puts event_arr[14]

      # which timezone are the dates we are reading
      Time.zone = "Europe/Berlin"
      account = Account.find(1458)

      ActsAsTenant.with_tenant(account) do
        event = Event.create!({
          account_id: account.id,
          name: event_arr[0],
          eventtemplate_id: event_arr[1],
          type: "StandardEvent",
          duration: event_arr[8],
          durationunit_id: 2,
          start_date: (Time.zone.parse(event_arr[9])&.to_datetime unless event_arr[9].nil?),
          end_date: (Time.zone.parse(event_arr[10])&.to_datetime unless event_arr[10].nil?),
          product_location_id: event_arr[11],
          use_product_location: true,
          full_price_cents: event_arr[12],
          early_signup_pricing: (true unless event_arr[13] == ''),
          price_early_signup_cents: event_arr[13],
          early_signup_deadline: (Time.zone.parse(event_arr[14]).to_datetime unless event_arr[14].nil?),
          eventtype_id: Eventtemplate.find(event_arr[1]).eventtype_id,
          #eventtype_id: 2670,
          max_additional_participants: 0,
          maxparticipants: 99,
          paymentmethods: Paymentmethod.all.where(id: 4),
          #tags: Event::Tag.all.where(id: event_arr[3]),
          product_tags: Product::Tag.all.where("id in (#{event_arr[2]})"),
          planningstatus_id: 2,
          onlinestatus_id: 2,
          generate_invoice: 0,
          vat_id: 2,
          allow_signup: true
        })
        i = i + 1
        puts "Created event no.:" + i.to_s
      end
    end
    puts i.to_s + " Events imported"
  end
end
