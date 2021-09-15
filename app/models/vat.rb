class Vat < ActiveRecord::Base

  #acts_as_tenant(:account)

  has_many :invoicepositions, class_name: 'Billing::Invoiceposition', :foreign_key => 'vat_id', dependent: :destroy
  has_many :eventbookings
  has_many :events
  has_many :items
  has_many :vat_revenue_accounts
  belongs_to :vat_country
  belongs_to :account

  translates :name

  validates :value, numericality: { greater_than_or_equal_to: 0, less_than: 1 }

  def to_s
    if vat_country
      "#{vat_country.country} - #{name}"
    else
      name
    end
  end

  # check if Vat is in use
  def allow_delete?
    if events.any? || items.any? || vat_revenue_accounts.any?
      false
    else
      true
    end
  end
end
