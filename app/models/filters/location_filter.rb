# filter by the event's location
class LocationFilter < Filter
  def self.model_name
    Filter.model_name
  end

  geocoded_by :location
  after_validation :geocode

  validates :location, :distance, presence: true

  def scope_name
    :filter_by_location
  end

  def scope_params
    [distance, [latitude, longitude]]
  end
end
