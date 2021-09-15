# holds a template that can be bound to a context. renderable as jsonp
class Widget < ActiveRecord::Base
  acts_as_tenant(:account)

  # require uniqueness even across all accounts, as we fetch qidgets by their token
  validates :token, uniqueness: { case_sensitive: false }
  validates :name, :html, presence: true

  before_create { self.token = SecureRandom.uuid }

  scope :eventtemplates, -> { where(widgetscope: "eventtemplates") }
  scope :events, -> { where("widgetscope = ", "'events'") }

  WIDGETTYPES = %w(bundle event).freeze

  def to_s
    name
  end

  def get_url
    if widgettype == ''
    else
    end
  end

  module Placeholder
    # a list of allowed placeholders provided by Eventtemplate
    class Eventtemplate
      PLACEHOLDERS = %w(stylesheet events name).freeze

      def self.each
        PLACEHOLDERS.each do |placeholder|
          yield placeholder
        end
      end
    end

    # a list of allowed placeholders provided by Event
    class Event
      PLACEHOLDERS = %w(
        name start_date start_time end_date end_time price account street zip city country
        eventorganizer location shortdescription longdescription bottom_text paymentmethods
        coaches maxparticipants remaining_seats show_link details_link
        signup_link request_link
      ).freeze

      def self.each
        PLACEHOLDERS.each do |placeholder|
          yield placeholder
        end
      end
    end

    class Coach
      PLACEHOLDERS = %w(
        id lastname firstname tel gender gender_indirect email price_unit active title
        image_file_name image_content_type image_file_size image_updated_at price_cents
        homepage_url homepage_url_target_blank created_at updated_at
      ).freeze

      def self.each
        PLACEHOLDERS.each do |placeholder|
          yield placeholder
        end
      end
    end

  end
end
