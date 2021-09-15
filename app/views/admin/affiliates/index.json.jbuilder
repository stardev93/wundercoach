json.array!(@affiliates) do |affiliate|
  json.extract! affiliate, :id, :name, :name_addon, :lastname, :firstname, :street, :zip, :city, :country, :email
  json.url affiliate_url(affiliate, format: :json)
end
