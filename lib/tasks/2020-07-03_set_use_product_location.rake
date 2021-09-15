namespace :wc do
  desc "Set use_product_location for all events"
  task :set_use_product_location => :environment do
    j = 0

    Event.all.order("id ASC").find_each do |event|
      puts "Adjusting location use for " + event.to_s
      if event.product_location_id.nil?
        event.use_product_location = false
      else
        puts "=====> product_location found: " + event.product_location.to_s
        event.use_product_location = true
      end
      event.save
    end
  end
end
