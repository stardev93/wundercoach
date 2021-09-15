class WcoachMailer < ApplicationMailer
  # Wundercoach Mailer class for system mails
  # implements smtp settings

  after_action :set_delivery_options

  default from: 'hello@wundercoach.net'
  layout 'mailer'

  WcoachMailer.default_options =
          {
            delivery_method: :smtp,
            reply_to: "hello@wundercoach.net <hello@wundercoach.net>",
            from: "hello@wundercoach.net <hello@wundercoach.net>"
          }

  private

  def set_delivery_options
  #   # get active smtpserver for wundercoach
  #   # merge the settings
    smtp_settings = {
                      user_name: "go@wundercoach.net",
                      password: "61d2c1Uk4",
                      address: "mail.businesshosting24.com",
                      port: "465",
                      ssl: true
                    }
    mail.delivery_method.settings.merge!(smtp_settings)
  #
  end
end
