json.array!(@durationunits) do |durationunit|
  json.extract! durationunit, :id, :key, :name_plural, :name_singular, :description, :sortorder
  json.url durationunit_url(durationunit, format: :json)
end
