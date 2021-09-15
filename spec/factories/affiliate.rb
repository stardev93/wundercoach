FactoryGirl.define do
  factory :affiliate do
    name "Seminar 2 Go"
    name_addon { Faker::Company.bs }
    street { Faker::Address.street_name + ' ' + Faker::Address.building_number }
    zip { Faker::Address.zip }
    city { Faker::Address.city }
    country 'DE'
    email 'sascha.krone@seminar2go.com'
    firstname 'Sascha'
    lastname 'Krone'
    token { SecureRandom.uuid }
  end
end
