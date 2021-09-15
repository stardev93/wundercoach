class ApplicationMailer < ActionMailer::Base
  # ApplicationMailer is the top-level Mailer class
  
  default from: 'hello@wundercoach.net'
  layout 'mailer'

end
