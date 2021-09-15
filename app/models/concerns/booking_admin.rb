# Rails Admin configuration for Bookings
module BookingAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        field :account
        field :paymentplan
        field :created_at do
          date_format :short
        end
        field :valid_until do
          date_format :default
        end
      end
      edit do
        field :account
        field :paymentplan
      end
    end
  end
end
