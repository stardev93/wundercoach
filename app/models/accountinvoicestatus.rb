class Accountinvoicestatus < ActiveRecord::Base
  translates :name, :description

  has_many :accountinvoices
  acts_as_list

  translates :name, :description

  def to_s
    name
  end
end
