# Class for sending Emails to the Wundercoach's Administrators
# Required mailer: wundercoach standard mailer
class AdminMailer < WcoachMailer

  # sent to go@wundercoach.net when new account is created
  # from app/concepts/account/operation/register.rb
  def account_creation_notice(account)
    subject = 'Neue Registrierung für den Wundercoach'
    @account = account

    mail(
        to: 'go@wundercoach.net',
        subject: subject)

    # mail.delivery_method.settings.merge!(delivery_options)

  end
end
