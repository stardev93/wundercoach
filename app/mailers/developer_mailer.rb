# Class for sending Emails to the Wundercoach's Administrators
# Required mailer: wundercoach standard mailer
class DeveloperMailer < WcoachMailer
  layout 'developer_mailer'
  def failure_notice(subject, message)
    @message = message
    mail(to: 'stefan.luetge@siliconplanet.com', subject: subject)
  end
end
