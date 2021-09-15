class Accountinvoicetype < ActiveRecord::Base
  translates :name, :description

  acts_as_list
  has_many :accountinvoices
  translates :name, :description
  def to_s
    name
  end
end
