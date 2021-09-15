json.array!(@mailskins) do |mailskin|
  json.extract! mailskin, :id, :key, :name, :htmlbody, :textbody
  json.url mailskin_url(mailskin, format: :json)
end
