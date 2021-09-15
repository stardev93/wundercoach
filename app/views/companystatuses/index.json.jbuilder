json.array!(@companystatuses) do |companystatus|
  json.extract! companystatus, :id, :name, :description, :key
  json.url companystatus_url(companystatus, format: :json)
end
