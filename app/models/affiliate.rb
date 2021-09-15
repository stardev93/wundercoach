# Affiliates manage multiple accounts
class Affiliate < ActiveRecord::Base
  has_many :accounts
  has_many :adpartners

  has_many :events, through: :accounts
  has_many :taggings, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :event_lists, dependent: :destroy
  has_many :orders, ->() { confirmed }, through: :events

  before_create ->() { self.token = SecureRandom.uuid }

  def to_s
    name
  end
end
