json.array!(@features) do |feature|
  json.extract! feature, :id, :key, :name, :description, :position, :version
  json.url feature_url(feature, format: :json)
end
