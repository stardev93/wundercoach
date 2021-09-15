namespace :wc do
  #require '/Applications/MAMP/htdocs/wundercoach/app/services/event/bundle_event_update_fromsubevent.rb'
  require Rails.root.join('app', 'services', 'event', 'bundle_event_update_fromsubevent.rb')
  require Rails.root.join('app', 'services', 'billing', 'eventbooking_service.rb')
  desc "Move existing bundles to events table"
  task :move_bundles => :environment do
    j = 0

    BundleEvent.delete_all
    #BundleEvent.where("account_id=660").delete_all

    # Account.where("id=660").order("id ASC").find_each do |account|
    # Account.where("id=86").order("id ASC").find_each do |account|
    Account.where("deleted_at IS NULL").order("id ASC").find_each do |account|
      bundlecount = 0
      ActsAsTenant.current_tenant = account
      i = account.id
      puts ""
      puts "Account: " + account.id.to_s + ' ' + account.name.to_s

      Bundle.all.order("id ASC").each do |bundle|
        bundlecount = bundlecount + 1
        j = j + 1
        puts j.to_s + ": Moving " + bundle.id.to_s + ' ' + bundle.name.to_s
        bundle_id = bundle.id
        bundleevent = BundleEvent.create!(
          {
            type: "BundleEvent",
            account_id: account.id,
            name: bundle.name,
            shortdescription: bundle.shortdescription,
            longdescription: bundle.longdescription,
            allow_signup: bundle.allow_signup,
            bottom_text: bundle.bottom_text,
            onlinestatus_id: bundle.onlinestatus_id,
            planningstatus: Planningstatus.find_by(key: 'not_planned'),
            slug: bundle.slug,
            currency: bundle.currency,
            generate_invoice: bundle.generate_invoice,
            vat_id: bundle.vat_id,
            digimember_id: bundle.digimember_id,
            full_price_cents: bundle.price_cents,
            max_additional_participants: 0,
            eventtype: Eventtype.all.first
          }
        )

        puts '---------------------------'
        puts 'assigned orders'
        puts '---------------------------'
        bundle.orders.each do |order|
          order.product_id = bundleevent.id
          order.product_type = "BundleEvent"
          order.save!

          #order the bundle itself
          # Eventbooking.skip_callback(:create, :before, :event_has_free_seats?)
          # EventbookingService.new.create_eventbooking(order, bundleevent)
          # if !bundleevent.booked_up?
          #   puts "bundleevent:" + bundleevent.to_s
          #   bundleevent.eventbookings.create({
          #     address: order&.eventbookings&.first&.address,
          #     billing_address: order&.eventbookings&.first&.billing_address,
          #     eventbookingstatus: Eventbookingstatus.find_by(key: 'confirmed'),
          #     booking_date: Time.now,
          #     order: order,
          #     additional_data: order.additional_data
          #   })
          # end
        end

        puts '---------------------------'
        puts 'assigned events'
        puts '---------------------------'
        bundle.events.each do |event|
          puts "event: "
          puts event.id.to_s
          puts event.to_s
          begin
            #EventSubevent.skip_callback(:commit, :after, :update_parent_event)
            subevent = EventSubevent.create!(
              {
                event: bundleevent,
                subevent_id: event.id
              }
            )
          rescue Exception => e
            puts "Error:"
            puts subevent
            puts "#{e.class}"
            #raise e
          end

          puts subevent
        end

        # go through orders one more time to create order for bundleevents
        # bundle.orders.each do |order|
        #   #order the bundle itself
        #   # Eventbooking.skip_callback(:create, :before, :event_has_free_seats?)
        #   EventbookingService.new.create_eventbooking(order, bundleevent)
        # end

      end
      account_bundle_count = account.bundles.count
      puts "Count new created BundleEvents: " + account_bundle_count.to_s
      puts "Count old Bundles: " + bundlecount.to_s
      puts "DIFF!!" if bundlecount != account_bundle_count

      # EventSubevent.all.each do |eventsubevent|
      #   @bundle_event = BundleEventUpdateFromSubevent.new(eventsubevent.event, eventsubevent.subevent).perform
      # end
    end
  end
end
