# how to query eventbookings
# query {
#   eventbookings {
#     id
#     addressId
#     address(id: "addressId") {
#       id
#       company
#       firstname
#       lastname
#       gender
#       street
#       zip
#       city
#       country
#       email
#       telephone
#     }
#     billingAddressId
#     billingAddress(id: "billingAddressId") {
#       id
#       company
#       firstname
#       lastname
#       gender
#       street
#       zip
#       city
#       country
#       email
#       telephone
#     }
#     orderId
#     contactId
#     comment
#     createdAt
#     updatedAt
#   }
# }

module Types
  class EventbookingType < Types::BaseObject
    field :id, ID, null: false
    field :event_id, String, null: false
    field :eventbookingstatus_id, String, null: false
    field :early_booking_applies, String, null: true

    field :address_id, String, null: true
    field :address, Types::AddressType, null: true do
      argument :id, ID, required: true
    end

    field :billing_address_id, String, null: true
    field :billing_address, Types::AddressType, null: true do
      argument :id, ID, required: true
    end

    #field :additional_data, String, null: true

    field :order_id, String, null: true
    field :contact_id, String, null: true
    field :comment, String, null: true

    field :created_at, String, null: true
    field :updated_at, String, null: true
  end
end
