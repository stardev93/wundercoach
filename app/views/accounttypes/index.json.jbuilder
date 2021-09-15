json.array!(@accounttypes) do |accounttype|
  json.extract! accounttype, :id, :name, :description, :key
  json.url accounttype_url(accounttype, format: :json)
end
