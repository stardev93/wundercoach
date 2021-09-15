module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :coaches, [Types::CoachType], null: false

    def coaches
      Coach.all
    end

    field :coach, Types::CoachType, null: false do
      argument :id, ID, required: true
    end

    def coach(id:)
      Coach.find(id)
    end

    field :events, [Types::EventType], null: false

    def events
      Event.all
    end

    field :event, Types::EventType, null: false do
      argument :id, ID, required: true
    end

    def event(id:)
      Event.find(id)
    end

    field :eventbookings, [Types::EventbookingType], null: false

    def eventbookings
      Eventbooking.all
    end

    field :eventbooking, Types::EventbookingType, null: false do
      argument :id, ID, required: true
    end

    def eventbooking(id:)
      Eventbooking.find(id)
    end

    field :eventtypes, [Types::EventtypeType], null: false

    def eventtypes
      Eventtype.all
    end

    field :eventtype, Types::EventtypeType, null: false do
      argument :id, ID, required: true
    end

    def eventtype(id:)
      Eventtype.find(id)
    end

    field :addresses, [Types::AddressType], null: false

    def addresses
      Address.all
    end

    field :address, Types::AddressType, null: false do
      argument :id, ID, required: true
    end

    def address(id:)
      Address.find(id)
    end
  end
end
