json.array!(@coaches) do |coach|
  json.extract! coach, :id, :lastname, :firstname, :tel, :gender, :email
  json.url coach_url(coach, format: :json)
end
