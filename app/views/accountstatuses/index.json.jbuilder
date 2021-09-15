json.array!(@accountstatuses) do |accountstatus|
  json.extract! accountstatus, :id, :key, :sortorder, :name, :comments
  json.url accountstatus_url(accountstatus, format: :json)
end
