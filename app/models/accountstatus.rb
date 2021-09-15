class Accountstatus < ActiveRecord::Base
  translates :name, :comments

  def to_s
    name
  end
end
