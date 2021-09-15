# advertises events, gets a commission for each initiated order
class Adpartner < ActiveRecord::Base
  belongs_to :affiliate
  has_many :orders, ->() { confirmed }
  has_many :websites
  include HasCountry

  validates :commission_relative, numericality: { greater_than_or_equal_to: 0, less_than: 100 }
  validates :commission_absolute, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }
  validates :commission_relative, :commission_absolute, presence: true

  include HasCountry

  def to_s
    name
  end
end
