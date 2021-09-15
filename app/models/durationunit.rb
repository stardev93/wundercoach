class Durationunit < ActiveRecord::Base
  translates :name_singular, :name_plural, :description

  def to_s
    name_singular
  end
end
