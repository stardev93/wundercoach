class User < ActiveRecord::Base
  # For changing your user password
  class PasswordForm < Reform::Form
    property :password
    property :password_confirmation, virtual: true

    validates :password, length: { minimum: 6 }

    validate do
      errors.add(:password_confirmation, I18n.t('errors.messages.confirmation', attribute: I18n.t(:password))) if password != password_confirmation
    end
  end
end
