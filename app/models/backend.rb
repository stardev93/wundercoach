class Backend < ActiveRecord::Base
  self.abstract_class = true

  include Filterable

  scope :new_accounts, ->(date_from) { where(created_at: { created_at: date_from }) }
  scope :start_date, ->(date) { where("created_at >= ?", date) }
  scope :end_date, ->(date) { where("created_at <= ?", date) }

  def self.new_accounts_count(date_from, date_to)
    Account.where("created_at >= '#{date_from}' and created_at <= '#{date_to}'").count
  end

  def self.new_accounts_turnover(date_from, date_to)
    Booking.joins(:paymentplan).where("valid_from >= #{date_from}").where("valid_until <= #{date_to}").where(is_current: true).sum(:price)
  end

  def self.mrr(date_from, date_to)
    Booking.joins(:paymentplan).where("valid_from >= #{date_from}").where("valid_until <= #{date_to}").where(is_current: true).sum(:price)
  end
end
