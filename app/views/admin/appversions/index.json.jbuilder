json.array!(@appversions) do |appversion|
  json.extract! appversion, :id, :name, :version_number, :version_string
  json.url appversion_url(appversion, format: :json)
end
