FactoryGirl.define do
  factory :address do
    lastname "Mustermann"
    firstname "Max"
    gender "male"
    telephone "01234567889"
    sequence(:email) {|n| "test#{n}@test.com" }
    zip 11_111
    city "Hamburg"
    street "Henriettenweg"
    country "DE"
  end
end
