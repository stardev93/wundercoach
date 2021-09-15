json.array!(@mailskinassets) do |mailskinasset|
  json.extract! mailskinasset, :id, :mailskin_id, :mailskinasset
  json.url mailskinasset_url(mailskinasset, format: :json)
end
