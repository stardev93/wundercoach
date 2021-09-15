json.array!(@assets) do |asset|
  json.extract! asset, :id, :name, :asset, :comments, :status
  json.url asset_url(asset, format: :json)
end
