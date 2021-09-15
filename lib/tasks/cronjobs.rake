namespace :cronjob do
  desc 'Runs all cronjobs in the right order'
  task run_all: :environment do
    Rake::Task['cronjob:replace_expired_bookings'].invoke
    Rake::Task['cronjob:create_billing_period_successors'].invoke
    Rake::Task['cronjob:send_expiry_reminder'].invoke
  end

  desc 'Replaces all expired bookings.'
  task replace_expired_bookings: :environment do
    puts 'Fetching expired Bookings ...'
    expired_bookings = Booking.recently_expired
    puts "Found #{expired_bookings.count}"
    expired_bookings.each do |booking|
      ActsAsTenant.with_tenant booking.account do
        puts "Replacing Booking of Account #{booking.account}"
        booking.expire!
      end
    end
    puts 'Done.'
  end

  desc 'Finds expired billingperiods and creates and charges their successors'
  task create_billing_period_successors: :environment do
    puts 'Creating new BillingPeriods ...'
    Account.all.find_each do |account|
      ActsAsTenant.with_tenant account do
        period = BillingPeriod.reorder(id: :asc).last # fetch current period
        if period&.expired?
          if period.booking.expired?
            puts "#{account}: Please replace expired bookings before creating new billing periods"
          else
            puts "Creating new BillingPeriod for Account #{account}"
            period.expire!
          end
        end
      end
    end
    puts 'Done.'
  end

  desc 'Send reminder trial expiry emails'
  task send_expiry_reminder: :environment do
    # Sending reminder 5 days before expiry..."
    puts 'Sending reminder 5 days before expiry...'
    i = 0
    Booking.trial_booking_reminder_one.find_each do |booking|
      # Skip deleted accounts
      next unless booking.account&.email
      # Skip if a billable next booking exists
      next if booking.account.bookings.last.billable?
      booking.send_trial_expiry_reminder_one
      i += 1
      puts "Sending reminder for #{booking.account} to #{booking.account.email}"
    end
    puts "#{i} reminder emails sent"
    puts ' '

    # Sending reminder 1 day before expiry..."
    i = 0
    puts 'Sending reminder 1 day before expiry...'
    Booking.trial_booking_reminder_two.find_each do |booking|
      booking.send_trial_expiry_reminder_two
      i += 1
      puts "Sending reminder for #{booking.account} to #{booking.account.email}"
    end
    puts "#{i} reminder emails sent"
    puts ' '

    # Sending reminder directly after expiry..."
    i = 0
    puts 'Sending reminder directly after expiry...'
    Booking.trial_expired_one.find_each do |booking|
      booking.send_trial_expired_one
      i += 1
      puts "Sending trial expiry notification for #{booking.account} to #{booking.account.email}"
    end
    puts "#{i} reminder emails sent"
    puts ' '

    # Sending reminder 5 days after expiry..."
    i = 0
    puts 'Sending reminder 5 days after expiry...'
    Booking.trial_expired_two.find_each do |booking|
      booking.send_trial_expired_two
      i += 1
      puts "Sending trial expiry notification for #{booking.account} to #{booking.account.email}"
    end
    puts "#{i} reminder emails sent"
    puts ' '
  end
end
