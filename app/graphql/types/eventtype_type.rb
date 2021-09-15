module Types
  class EventtypeType < Types::BaseObject
    field :id, ID, null: false
    field :key, String, null: false
    field :name, String, null: false
  end
end
