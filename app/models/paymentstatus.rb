class Paymentstatus < ActiveRecord::Base
  has_many :eventbookings

  translates :name, :comment

  def to_s
    name
  end
end
