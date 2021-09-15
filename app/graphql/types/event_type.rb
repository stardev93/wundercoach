# how to query events
# query {
#   events {
#     id
#     slug
#     name
#     shortdescription
#     longdescription
#     eventbookings {
#         id
#         address(id: "addressId") {
#           firstname
#           lastname
#         }
#     }
#     coaches {
#       id
#       lastname
#       firstname
#       title
#       image
#       tel
#       email
#     }
#   }
# }

#ToDo:
# search by date, period, past, future type etc
# include tags
module Types
  class EventType < Types::BaseObject
    field :id, ID, null: false
    field :account_id, ID, null: false
    field :type, String, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :shortdescription, String, null: true
    field :longdescription, String, null: true
    field :bottom_text, String, null: true

    field :start_date, String, null: true
    field :end_date, String, null: true

    field :colorcode, String, null: true

    field :eventbookings, [Types::EventbookingType], null: true
    field :coaches, [Types::CoachType], null: true
    field :duration, String, null: true
    field :durationunit_id, String, null: true
    field :eventtype_id, String, null: true
    field :onlinestatus_id, String, null: true
    field :planningstatus_id, String, null: true

    field :eventtype_id, String, null: true
    field :eventtype, [Types::EventtypeType], null: true

    field :allow_signup, String, null: true
    field :external_signup_url, String, null: true
    field :external_signup_text, String, null: true
    field :redirect_message, String, null: true

    field :full_price_cents, String, null: true
    field :price_early_signup_cents, String, null: true
    field :early_signup_pricing, String, null: true
    field :currency, String, null: true
    field :generate_invoice, String, null: true

    field :vat_id, String, null: true
    field :maxparticipants, String, null: true
    field :duration, String, null: true

    field :eventorganizer, String, null: true
    field :location, String, null: true
    field :street, String, null: true
    field :streetno, String, null: true
    field :zip, String, null: true
    field :city, String, null: true
    field :country, String, null: true
    field :googlemapslocation, String, null: true
    field :latitude, String, null: true
    field :longitude, String, null: true

    field :eventtemplate_id, String, null: true
    field :show_remaining_seats_count, String, null: true
    field :max_additional_participants, String, null: true
    field :latest_signup_date, String, null: true
    field :early_signup_deadline, String, null: true
    field :reservation_expiry, String, null: true

    field :meta_title, String, null: true
    field :meta_description, String, null: true
    field :meta_keywords, String, null: true


    field :created_at, String, null: true
    field :updated_at, String, null: true

  end
end
