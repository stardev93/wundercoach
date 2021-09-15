require 'reform/form/coercion'
# Form for updating and validating the account's sofort.com access data
class Address < ActiveRecord::Base
  # validates and saves addresses
  class AddressForm < Reform::Form
    property :lastname
    property :firstname
    property :company
    property :telephone
    property :gender
    property :email
    property :street
    property :zip
    property :city
    property :country
    validates :lastname, :firstname, :gender, :email, :street, :zip, :city, :country, presence: true
    validates :email, email: true
  end
end
