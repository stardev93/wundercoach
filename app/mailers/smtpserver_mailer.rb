class SmtpserverMailer < ApplicationMailer
  # class for testing smtpserver settings
  # Attention: testing of custom smtpserver only! The wundercoach_standard mail server can not be tested
  # supply user and smtpserver to test
  # Required mailer: custom

  #after_action :get_smtpserver
  # sent from
  # app/controllers/smtpservers_controller.rb
  def smtpsendtest(account, smtpserver, user)
    # get the custom mailer
    # todo: check if custom mailer is configured
    @subject = 'Wundercoach Test-Email'
    @user = user

    @smtpserver = account.get_smtp_server

    SmtpserverMailer.smtp_settings.merge!(@smtpserver.get_delivery_options)
    mail(to: @user.email,
         subject: @subject,
         delivery_method: :smtp,
         from: "#{@smtpserver.from_name} <#{@smtpserver.from_address}>",
         reply_to: @smtpserver.replyto_address)
  end

end
