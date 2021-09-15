module Types
  class AddressType < Types::BaseObject
    field :id, ID, null: false
    field :company, String, null: true
    field :firstname, String, null: false
    field :lastname, String, null: true
    field :gender, String, null: true
    field :street, String, null: true
    field :zip, String, null: true
    field :city, String, null: true
    field :country, String, null: true
    field :email, String, null: true
    field :telephone, String, null: true
  end
end
