class Item < ActiveRecord::Base

  acts_as_tenant(:account)
  has_many :businessdocumentpositions, as: :product
  belongs_to :account
  belongs_to :vat

  monetize :price_cents, with_model_currency: :currency, allow_nil: true

  def to_s
    name
  end
end
