class User < ActiveRecord::Base
  # Create an Order from the backend
  class UpdatePassword < Trailblazer::Operation
    step Contract::Build(constant: PasswordForm)
    step Contract::Validate()
    step Contract::Persist()
  end
end
