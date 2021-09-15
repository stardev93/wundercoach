class VatCountry < ActiveRecord::Base
  include HasCountry
  has_many :vats

  def to_s
    country_name
  end
end
