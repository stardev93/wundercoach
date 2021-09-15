FactoryGirl.define do
  factory :eventtype do
    sequence(:key) {|n| "seminartyp-#{n}" }
    sequence(:name) {|n| "seminartyp-#{n}" }
  end
end
