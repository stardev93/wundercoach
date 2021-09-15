# how to query coaches
# query {
#   coaches {
#     id
#     lastname
#     firstname
#     title
#     label
#     image
#     tel
#     email
#   }
# }

# how to query a single coach
# query {
#   coach(id: "294") {
#     id
#     lastname
#     firstname
#     title
#     label
#     image
#     tel
#     email
#   }
# }

#ToDo:
# get full path to image as a method or computed property
# search by lastname, firstname, status etc.
module Types
  class CoachType < Types::BaseObject
    field :id, ID, null: false
    field :active, Boolean, null: true
    field :lastname, String, null: true
    field :firstname, String, null: true
    field :gender, String, null: true
    field :title, String, null: true

    field :label, String, null: true
    field :description, String, null: true

    field :tel, String, null: true
    field :email, String, null: true

    field :price_cents, String, null: true
    field :price_unit, String, null: true

    field :image, String, null: true

    field :homepage_url, String, null: true
    field :homepage_url_target_blank, String, null: true

    field :created_at, String, null: true
    field :updated_at, String, null: true
  end
end
