json.array!(@companies) do |company|
  json.extract! company, :id, :account_id, :name, :name_addon, :comments, :zip, :city, :street, :streetno, :country, :gender, :firstname, :lastname, :tel1, :tel2, :fax, :email, :homepage, :logo, :companystatus_id, :companynumber, :vat_number
  json.url company_url(company, format: :json)
end
