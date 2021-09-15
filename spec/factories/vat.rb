FactoryGirl.define do
  factory :vat do
    key "regular_vat"
    name "normaler Satz: 19,00%"
    value 0.19
    position 2
    vat_country { create(:vat_country) }
  end
end
