class User < ActiveRecord::Base
  # Create a User from the backend
  class Create < Trailblazer::Operation
    step :model!
    step Contract::Build(constant: UserForm)
    step Contract::Validate()
    step :generate_password!
    step Contract::Persist()
    success ->(model:, **) { model.setup_activation }
    success ->(model:, **) { model.roles << Role.find_by(name: 'user') }
    # FIXME: internal_activation_needed_email takes only one argument, and it
    # doesn't send the password anymore
    success ->(model:, **) { UserMailer.delay.internal_activation_needed_email(model) }

    private

    def model!(options)
      options['model'] = User.internal.new
    end

    # generated password is a generic string,
    # containing "a-z", "A-Z", "-" and "_"
    # length may vary, but will usually be longer than 8 chars
    def generate_password!(model:, **)
      model.password = SecureRandom.urlsafe_base64(8)
    end
  end
end
