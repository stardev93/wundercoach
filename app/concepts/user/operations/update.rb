class User < ActiveRecord::Base
  # Create a User from the backend
  class Update < Trailblazer::Operation
    step Contract::Build(constant: UserForm)
    step Contract::Validate()
    step Rescue(ActiveRecord::RecordNotUnique, handler: :add_not_unique_error!) {
      step Contract::Persist()
    }

    private

    def add_not_unique_error!(_exception, options)
      options['contract.default'].errors.add(:email, I18n.t('errors.messages.taken'))
      false
    end
  end
end
