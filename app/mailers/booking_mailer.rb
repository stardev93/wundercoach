# Handling booking related emails
# we have 5 mailers that remind the user of upgrading his plan
# 5 days before expiry: send_expiry_reminder_one
# 1 day before expiry: send_expiry_reminder_two
# same day: send_trial_expired_one
# 5 days after expiry: send_trial_expired_two
# the mailers are triggered by a cron and a rake task rake wundercoach:send_expiry_reminder
# sent from app/models/bookings/booking.rb


class BookingMailer < WcoachMailer
  # send first reminder 5 (or any number of) days before trial expires
  def send_expiry_reminder_one(booking)
    @booking = booking
    @account = @booking.account
    @remaining_days = booking.remaining_days
    @subject = I18n.t(:send_expiry_reminder_one_subject, remaining_days: @remaining_days)

    mail(to: @account.email,
         subject: @subject,
         bcc: 'go@wundercoach.net')
  end

  # send second reminder that trial expires 1 day before expiry
  def send_expiry_reminder_two(booking)
    @booking = booking
    @account = @booking.account
    @subject = I18n.t(:send_expiry_reminder_two_subject)

    mail(to: @account.email,
         subject: @subject,
         bcc: 'go@wundercoach.net')
  end

  # send informational email the same day the Trial expired
  def send_trial_expired_one(booking)
    @booking = booking
    @account = @booking.account
    @subject = I18n.t(:send_trial_expired_one_subject)

    mail(to: @account.email,
         subject: @subject,
         bcc: 'go@wundercoach.net')
  end

  # send informational email 5 days after the Trial expired
  def send_trial_expired_two(booking)
    @booking = booking
    @account = @booking.account
    @subject = I18n.t(:send_trial_expired_one_subject)

    mail(to: @account.email,
         subject: @subject,
         bcc: 'go@wundercoach.net')
  end
end
