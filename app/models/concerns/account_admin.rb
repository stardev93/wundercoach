# Rails Admin configuration for Accounts
module AccountAdmin
  extend ActiveSupport::Concern

  # RailsAdmin error
  # https://github.com/sferik/rails_admin/issues/1183
  included do
    rails_admin do
      list do
        field :name
        field :current_booking
        field :subdomain
        field :homepage
        field :email
      end
    end
  end
end
