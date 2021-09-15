json.array!(@placeholders) do |placeholder|
  json.extract! placeholder, :id, :name, :description
  json.url admin_placeholder_url(placeholder, format: :json)
end
