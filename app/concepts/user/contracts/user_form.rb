require 'reform/form/validation/unique_validator'
# default user form for both creating and updating
class UserForm < Reform::Form
  property :lastname
  property :firstname
  property :gender
  property :email
  property :tel
  property :zip
  property :city
  property :street
  property :street_no
  property :country
  property :has_message
  property :time_zone

  validates :email, email: true, unique: true
end
