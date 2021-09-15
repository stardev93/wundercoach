class Smtpserver < ActiveRecord::Base
  # Create a User from the backend

  class Update < Trailblazer::Operation

    step Contract::Build(constant: SmtpserverForm)
    step Contract::Validate()
    step Contract::Persist()

  end
end
