namespace :wc do
  desc "Move existing eventemplates to events table"
  task :move_eventtemplates => :environment do
    j = 0

    Account.all.order("id ASC").find_each do |account|
      count = 0
      ActsAsTenant.current_tenant = account
      i = account.id
      puts ""
      puts "Account: " + account.id.to_s + ' ' + account.name.to_s

      account_et_count = account.eventtemplates.count
      puts "Eventtemplate.count: " + account_et_count.to_s

      Eventtemplate.all.order("id ASC").each do |eventtemplate|
        count = count + 1
        j = j + 1
        puts j.to_s + ": Moving " + eventtemplate.id.to_s + ' ' + eventtemplate.name.to_s + ' ' + eventtemplate.eventtype.to_s
        event = Event.create_from_template(eventtemplate)
        event.type = "Eventtemplate"
        begin
          event.save!
        rescue => exception
          puts exception.backtrace
          raise # always reraise
        end
      end
      puts "Counts: " + count.to_s + ' - ' + account_et_count.to_s
      puts "DIFF!!" if count != account_et_count
    end
  end
end

# namespace :wc do
#   desc "Remove eventemplates from events table"
#   task :move_eventtemplates => :environment do
#     Event.all.where(:type, "Eventtemplate").each do |event|
#       event.delete
#     end
#   end
# end
