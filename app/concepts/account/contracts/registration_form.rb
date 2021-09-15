require 'reform/form/validation/unique_validator'
class Account < ApplicationRecord
  # For registering new accounts from frontend
  class RegistrationForm < Reform::Form
    property :name
    property :firstname
    property :lastname
    property :gender
    property :homepage
    property :terms_of_service, virtual: true
    property :privacy_policy_terms, virtual: true

    property :creator, populate_if_empty: User do
      property :email
      property :password
      validates :email, email: true, unique: true
      validates :email, :password, presence: true
      validates :password, length: { minimum: 6 }
    end

    validates :terms_of_service, acceptance: true
    validates :privacy_policy_terms, acceptance: true
    validates :name, :firstname, :lastname, :gender, presence: true
  end
end
