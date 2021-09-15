FactoryGirl.define do
  factory :appversion do
    sequence(:name) {|n| "#{n}" }
  end
end
