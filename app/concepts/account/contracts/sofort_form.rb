class Account < ApplicationRecord
  # Form for updating and validating the account's sofort.com access data
  class SofortForm < Reform::Form
    property :sofort_user_id
    property :sofort_api_key
    property :sofort_project_id

    validates :sofort_user_id, :sofort_api_key, :sofort_project_id, presence: true
  end
end
